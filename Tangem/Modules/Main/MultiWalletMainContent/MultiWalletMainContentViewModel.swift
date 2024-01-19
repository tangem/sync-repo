//
//  MultiWalletMainContentViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import CombineExt

final class MultiWalletMainContentViewModel: ObservableObject {
    @Injected(\.swapAvailabilityProvider) private var swapAvailabilityProvider: SwapAvailabilityProvider

    // MARK: - ViewState

    @Published var isLoadingTokenList: Bool = true
    @Published var sections: [Section] = []
    @Published var notificationInputs: [NotificationViewInput] = []
    @Published var tokensNotificationInputs: [NotificationViewInput] = []

    @Published var isScannerBusy = false
    @Published var error: AlertBinder? = nil
    @Published var rateAppBottomSheetViewModel: RateAppBottomSheetViewModel?
    @Published var isAppStoreReviewRequested = false

    weak var delegate: MultiWalletMainContentDelegate?

    var footerViewModel: MainFooterViewModel? {
        guard canManageTokens else { return nil }

        return MainFooterViewModel(
            isButtonDisabled: false,
            buttonTitle: Localization.mainManageTokens,
            buttonAction: weakify(self, forFunction: MultiWalletMainContentViewModel.openManageTokens)
        )
    }

    var isOrganizeTokensVisible: Bool {
        guard canManageTokens else { return false }

        if sections.isEmpty {
            return false
        }

        let numberOfTokens = sections.reduce(0) { $0 + $1.items.count }
        let requiredNumberOfTokens = 2

        return numberOfTokens >= requiredNumberOfTokens
    }

    // MARK: - Dependencies

    private let userWalletModel: UserWalletModel
    private let userWalletNotificationManager: NotificationManager
    private let tokensNotificationManager: NotificationManager
    private let tokenSectionsAdapter: TokenSectionsAdapter
    private let tokenRouter: SingleTokenRoutable
    private let optionsEditing: OrganizeTokensOptionsEditing
    private unowned let coordinator: MultiWalletMainContentRoutable

    private var canManageTokens: Bool { userWalletModel.isMultiWallet }

    private var cachedTokenItemViewModels: [ObjectIdentifier: TokenItemViewModel] = [:]

    private let mappingQueue = DispatchQueue(
        label: "com.tangem.MultiWalletMainContentViewModel.mappingQueue",
        qos: .userInitiated
    )

    private let rateAppService = RateAppService()

    private let isPageSelectedSubject = PassthroughSubject<Bool, Never>()
    private var isUpdating = false

    private var bag = Set<AnyCancellable>()

    init(
        userWalletModel: UserWalletModel,
        userWalletNotificationManager: NotificationManager,
        tokensNotificationManager: NotificationManager,
        tokenSectionsAdapter: TokenSectionsAdapter,
        tokenRouter: SingleTokenRoutable,
        optionsEditing: OrganizeTokensOptionsEditing,
        coordinator: MultiWalletMainContentRoutable
    ) {
        self.userWalletModel = userWalletModel
        self.userWalletNotificationManager = userWalletNotificationManager
        self.tokensNotificationManager = tokensNotificationManager
        self.tokenSectionsAdapter = tokenSectionsAdapter
        self.tokenRouter = tokenRouter
        self.optionsEditing = optionsEditing
        self.coordinator = coordinator

        setup()
    }

    func onPullToRefresh(completionHandler: @escaping RefreshCompletionHandler) {
        if isUpdating {
            return
        }

        isUpdating = true
        userWalletModel.userTokensManager.sync { [weak self] in
            self?.isUpdating = false
            completionHandler()
        }
    }

    func deriveEntriesWithoutDerivation() {
        Analytics.log(.mainNoticeScanYourCardTapped)
        isScannerBusy = true
        userWalletModel.userTokensManager.deriveIfNeeded { [weak self] _ in
            DispatchQueue.main.async {
                self?.isScannerBusy = false
            }
        }
    }

    func startBackupProcess() {
        // TODO: Refactor this along with OnboardingInput generation
        if let cardViewModel = userWalletModel as? CardViewModel,
           let input = cardViewModel.backupInput {
            Analytics.log(.mainNoticeBackupWalletTapped)
            coordinator.openOnboardingModal(with: input)
        }
    }

    func onOpenOrganizeTokensButtonTap() {
        Analytics.log(.buttonOrganizeTokens)
        openOrganizeTokens()
    }

    private func setup() {
        subscribeToTokenListUpdatesIfNeeded()
        bind()
    }

    private func bind() {
        let sourcePublisherFactory = TokenSectionsSourcePublisherFactory()
        let tokenSectionsSourcePublisher = sourcePublisherFactory.makeSourcePublisher(for: userWalletModel)

        let organizedTokensSectionsPublisher = tokenSectionsAdapter
            .organizedSections(from: tokenSectionsSourcePublisher, on: mappingQueue)
            .share(replay: 1)

        organizedTokensSectionsPublisher
            .withWeakCaptureOf(self)
            .map { viewModel, sections in
                return viewModel.convertToSections(sections)
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self, ownership: .weak)
            .store(in: &bag)

        organizedTokensSectionsPublisher
            .withWeakCaptureOf(self)
            .sink { viewModel, sections in
                viewModel.removeOldCachedTokenViewModels(sections)
            }
            .store(in: &bag)

        organizedTokensSectionsPublisher
            .map { $0.flatMap(\.items) }
            .removeDuplicates()
            .map { $0.map(\.walletModelId) }
            .withWeakCaptureOf(self)
            .flatMapLatest { viewModel, walletModelIds in
                return viewModel.optionsEditing.save(reorderedWalletModelIds: walletModelIds)
            }
            .sink()
            .store(in: &bag)

        let userWalletNotificationsPublisher = userWalletNotificationManager
            .notificationPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .share(replay: 1)

        userWalletNotificationsPublisher
            .assign(to: \.notificationInputs, on: self, ownership: .weak)
            .store(in: &bag)

        let tokensNotificationsPublisher = tokensNotificationManager
            .notificationPublisher
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .share(replay: 1)

        tokensNotificationsPublisher
            .assign(to: \.tokensNotificationInputs, on: self, ownership: .weak)
            .store(in: &bag)

        userWalletModel
            .totalBalancePublisher
            .compactMap { $0.value }
            .withWeakCaptureOf(self)
            .sink { viewModel, _ in
                let walletModels = viewModel.userWalletModel.walletModelsManager.walletModels
                viewModel.rateAppService.registerBalances(of: walletModels)
            }
            .store(in: &bag)

        let allNotificationsPublisher = Publishers.CombineLatest(userWalletNotificationsPublisher, tokensNotificationsPublisher)
            .map { $0.0 + $0.1 }

        let isBalanceLoadedPublisher = userWalletModel
            .totalBalancePublisher
            .map { $0.value != nil }
            .removeDuplicates()

        Publishers.CombineLatest3(isPageSelectedSubject, isBalanceLoadedPublisher, allNotificationsPublisher)
            .map { isPageSelected, isBalanceLoaded, notifications in
                return RateAppRequest(
                    isLocked: false,
                    isSelected: isPageSelected,
                    isBalanceLoaded: isBalanceLoaded,
                    displayedNotifications: notifications
                )
            }
            .withWeakCaptureOf(self)
            .sink { viewModel, rateAppRequest in
                viewModel.rateAppService.requestRateAppIfAvailable(with: rateAppRequest)
            }
            .store(in: &bag)

        rateAppService
            .rateAppAction
            .withWeakCaptureOf(self)
            .sink { viewModel, rateAppAction in
                viewModel.handleRateAppAction(rateAppAction)
            }
            .store(in: &bag)
    }

    private func convertToSections(
        _ sections: [TokenSectionsAdapter.Section]
    ) -> [Section] {
        let factory = MultiWalletTokenItemsSectionFactory()

        if sections.count == 1, sections[0].items.isEmpty {
            return []
        }

        return sections.enumerated().map { index, section in
            let sectionViewModel = factory.makeSectionViewModel(from: section.model, atIndex: index)
            let itemViewModels = section.items.map { item in
                switch item {
                case .default(let walletModel):
                    // Fetching existing cached View Model for this Wallet Model, if available
                    let cacheKey = ObjectIdentifier(walletModel)
                    if let cachedViewModel = cachedTokenItemViewModels[cacheKey] {
                        return cachedViewModel
                    }
                    let viewModel = makeTokenItemViewModel(from: item, using: factory)
                    cachedTokenItemViewModels[cacheKey] = viewModel
                    return viewModel
                case .withoutDerivation:
                    return makeTokenItemViewModel(from: item, using: factory)
                }
            }

            return Section(model: sectionViewModel, items: itemViewModels)
        }
    }

    private func makeTokenItemViewModel(
        from sectionItem: TokenSectionsAdapter.SectionItem,
        using factory: MultiWalletTokenItemsSectionFactory
    ) -> TokenItemViewModel {
        return factory.makeSectionItemViewModel(
            from: sectionItem,
            contextActionsProvider: self,
            contextActionsDelegate: self,
            tapAction: weakify(self, forFunction: MultiWalletMainContentViewModel.tokenItemTapped(_:))
        )
    }

    private func removeOldCachedTokenViewModels(_ sections: [TokenSectionsAdapter.Section]) {
        let cacheKeys = sections
            .flatMap(\.walletModels)
            .map(ObjectIdentifier.init)
            .toSet()

        cachedTokenItemViewModels = cachedTokenItemViewModels.filter { cacheKeys.contains($0.key) }
    }

    private func subscribeToTokenListUpdatesIfNeeded() {
        if userWalletModel.userTokenListManager.initialized {
            isLoadingTokenList = false
            return
        }

        var tokenSyncSubscription: AnyCancellable?
        tokenSyncSubscription = userWalletModel.userTokenListManager.initializedPublisher
            .filter { $0 }
            .sink(receiveValue: { [weak self] _ in
                self?.isLoadingTokenList = false
                withExtendedLifetime(tokenSyncSubscription) {}
            })
    }

    private func tokenItemTapped(_ walletModelId: WalletModelId) {
        guard let walletModel = userWalletModel.walletModelsManager.walletModels.first(where: { $0.id == walletModelId }) else {
            return
        }

        coordinator.openTokenDetails(for: walletModel, userWalletModel: userWalletModel)
    }

    private func handleRateAppAction(_ action: RateAppAction) {
        rateAppBottomSheetViewModel = nil

        switch action {
        case .openAppRateDialog:
            rateAppBottomSheetViewModel = RateAppBottomSheetViewModel { [weak self] response in
                self?.rateAppService.respondToRateAppDialog(with: response)
            }
        case .openMailWithEmailType(let emailType):
            let userWallet = userWalletModel
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.feedbackRequestDelay) { [weak self] in
                let collector = NegativeFeedbackDataCollector(userWalletEmailData: userWallet.emailData)
                let recipient = userWallet.config.emailConfig?.recipient ?? EmailConfig.default.recipient
                self?.coordinator.openMail(with: collector, emailType: emailType, recipient: recipient)
            }
        case .openAppStoreReview:
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.feedbackRequestDelay) { [weak self] in
                self?.isAppStoreReviewRequested = true
            }
        }
    }
}

// MARK: Hide token

private extension MultiWalletMainContentViewModel {
    func hideTokenAction(for tokenItemViewModel: TokenItemViewModel) {
        let targetId = tokenItemViewModel.id
        let blockchainNetwork: BlockchainNetwork
        if let walletModel = userWalletModel.walletModelsManager.walletModels.first(where: { $0.id == targetId }) {
            blockchainNetwork = walletModel.blockchainNetwork
        } else if let entry = userWalletModel.userTokenListManager.userTokensList.entries.first(where: { $0.walletModelId == targetId }) {
            blockchainNetwork = entry.blockchainNetwork
        } else {
            return
        }

        let derivation = blockchainNetwork.derivationPath
        let tokenItem = tokenItemViewModel.tokenItem

        if userWalletModel.userTokensManager.canRemove(tokenItem, derivationPath: derivation) {
            showHideWarningAlert(tokenItem: tokenItemViewModel.tokenItem, blockchainNetwork: blockchainNetwork)
        } else {
            showUnableToHideAlert(currencySymbol: tokenItem.currencySymbol, blockchainName: tokenItem.blockchain.displayName)
        }
    }

    func showHideWarningAlert(tokenItem: TokenItem, blockchainNetwork: BlockchainNetwork) {
        error = AlertBuilder.makeAlert(
            title: Localization.tokenDetailsHideAlertTitle(tokenItem.currencySymbol),
            message: Localization.tokenDetailsHideAlertMessage,
            primaryButton: .destructive(Text(Localization.tokenDetailsHideAlertHide)) { [weak self] in
                self?.hideToken(tokenItem: tokenItem, blockchainNetwork: blockchainNetwork)
            },
            secondaryButton: .cancel()
        )
    }

    func showUnableToHideAlert(currencySymbol: String, blockchainName: String) {
        let message = Localization.tokenDetailsUnableHideAlertMessage(
            currencySymbol,
            blockchainName
        )

        error = AlertBuilder.makeAlert(
            title: Localization.tokenDetailsUnableHideAlertTitle(currencySymbol),
            message: message,
            primaryButton: .default(Text(Localization.commonOk))
        )
    }

    func hideToken(tokenItem: TokenItem, blockchainNetwork: BlockchainNetwork) {
        let derivation = blockchainNetwork.derivationPath
        userWalletModel.userTokensManager.remove(tokenItem, derivationPath: derivation)

        Analytics.log(
            event: .buttonRemoveToken,
            params: [
                Analytics.ParameterKey.token: tokenItem.currencySymbol,
                Analytics.ParameterKey.source: Analytics.ParameterValue.main.rawValue,
            ]
        )
    }
}

// MARK: Navigation

extension MultiWalletMainContentViewModel {
    func openManageTokens() {
        Analytics.log(.buttonManageTokens)

        let shouldShowLegacyDerivationAlert = userWalletModel.config.warningEvents.contains(where: { $0 == .legacyDerivation })
        var supportedBlockchains = userWalletModel.config.supportedBlockchains
        supportedBlockchains.remove(.ducatus)

        let settings = LegacyManageTokensSettings(
            supportedBlockchains: supportedBlockchains,
            hdWalletsSupported: userWalletModel.config.hasFeature(.hdWallets),
            longHashesSupported: userWalletModel.config.hasFeature(.longHashes),
            derivationStyle: userWalletModel.config.derivationStyle,
            shouldShowLegacyDerivationAlert: shouldShowLegacyDerivationAlert,
            existingCurves: (userWalletModel as? CardViewModel)?.card.walletCurves ?? []
        )

        coordinator.openManageTokens(with: settings, userTokensManager: userWalletModel.userTokensManager)
    }

    private func openOrganizeTokens() {
        coordinator.openOrganizeTokens(for: userWalletModel)
    }

    private func openBuy(for walletModel: WalletModel) {
        if let disabledLocalizedReason = userWalletModel.config.getDisabledLocalizedReason(for: .exchange) {
            error = AlertBuilder.makeDemoAlert(disabledLocalizedReason)
            return
        }

        tokenRouter.openBuyCryptoIfPossible(walletModel: walletModel)
    }

    private func openSell(for walletModel: WalletModel) {
        if let disabledLocalizedReason = userWalletModel.config.getDisabledLocalizedReason(for: .exchange) {
            error = AlertBuilder.makeDemoAlert(disabledLocalizedReason)
            return
        }

        tokenRouter.openSell(for: walletModel)
    }
}

// MARK: - Notification tap delegate

extension MultiWalletMainContentViewModel: NotificationTapDelegate {
    func didTapNotification(with id: NotificationViewId) {
        guard let notification = notificationInputs.first(where: { $0.id == id }) else {
            userWalletNotificationManager.dismissNotification(with: id)
            return
        }

        switch notification.settings.event {
        case let userWalletEvent as WarningEvent:
            handleUserWalletNotificationTap(event: userWalletEvent, id: id)
        default:
            break
        }
    }

    func didTapNotificationButton(with id: NotificationViewId, action: NotificationButtonActionType) {
        switch action {
        case .generateAddresses:
            deriveEntriesWithoutDerivation()
        case .backupCard:
            startBackupProcess()
        default:
            return
        }
    }

    private func handleUserWalletNotificationTap(event: WarningEvent, id: NotificationViewId) {
        switch event {
        default:
            assertionFailure("This event shouldn't have tap action on main screen. Event: \(event)")
        }
    }
}

// MARK: - MainViewPage protocol conformance

extension MultiWalletMainContentViewModel: MainViewPage {
    func onPageAppear() {
        isPageSelectedSubject.send(true)
    }

    func onPageDisappear() {
        isPageSelectedSubject.send(false)
    }
}

// MARK: Context actions

extension MultiWalletMainContentViewModel: TokenItemContextActionsProvider {
    func buildContextActions(for tokenItem: TokenItemViewModel) -> [TokenActionType] {
        guard
            let walletModel = userWalletModel.walletModelsManager.walletModels.first(where: { $0.id == tokenItem.id })
        else {
            return [.hide]
        }

        let actionsBuilder = TokenActionListBuilder()
        let utility = ExchangeCryptoUtility(
            blockchain: walletModel.blockchainNetwork.blockchain,
            address: walletModel.defaultAddress,
            amountType: walletModel.amountType
        )
        let canExchange = userWalletModel.config.isFeatureVisible(.exchange)
        let canSend = userWalletModel.config.hasFeature(.send) && walletModel.canSendTransaction
        let canSwap = userWalletModel.config.hasFeature(.swapping) && swapAvailabilityProvider.canSwap(tokenItem: tokenItem.tokenItem) && !walletModel.isCustom
        let isBlockchainReachable = !walletModel.state.isBlockchainUnreachable

        return actionsBuilder.buildTokenContextActions(
            canExchange: canExchange,
            canSend: canSend,
            canSwap: canSwap,
            canHide: canManageTokens,
            isBlockchainReachable: isBlockchainReachable,
            exchangeUtility: utility
        )
    }
}

extension MultiWalletMainContentViewModel: TokenItemContextActionDelegate {
    func didTapContextAction(_ action: TokenActionType, for tokenItem: TokenItemViewModel) {
        if case .hide = action {
            hideTokenAction(for: tokenItem)
        }

        guard
            let walletModel = userWalletModel.walletModelsManager.walletModels.first(where: { $0.id == tokenItem.id })
        else {
            return
        }

        switch action {
        case .buy:
            openBuy(for: walletModel)
        case .send:
            tokenRouter.openSend(walletModel: walletModel)
        case .receive:
            tokenRouter.openReceive(walletModel: walletModel)
        case .sell:
            openSell(for: walletModel)
        case .copyAddress:
            UIPasteboard.general.string = walletModel.defaultAddress
            delegate?.displayAddressCopiedToast()
        case .exchange:
            if let disabledLocalizedReason = userWalletModel.config.getDisabledLocalizedReason(for: .swapping) {
                error = AlertBuilder.makeDemoAlert(disabledLocalizedReason)
                return
            }

            Analytics.log(event: .buttonExchange, params: [.token: walletModel.tokenItem.currencySymbol])
            tokenRouter.openExchange(walletModel: walletModel)
        case .hide:
            return
        }
    }
}

// MARK: - Auxiliary types

extension MultiWalletMainContentViewModel {
    typealias Section = SectionModel<SectionViewModel, TokenItemViewModel>

    struct SectionViewModel: Identifiable {
        let id: AnyHashable
        let title: String?
    }
}

// MARK: - Convenience extensions

private extension TokenSectionsAdapter.Section {
    var walletModels: [WalletModel] {
        return items.compactMap(\.walletModel)
    }
}

// MARK: - Constants

private extension MultiWalletMainContentViewModel {
    private enum Constants {
        static let feedbackRequestDelay = 0.7
    }
}
