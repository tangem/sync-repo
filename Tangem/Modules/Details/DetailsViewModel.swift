//
//  DetailsViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import TangemSdk
import BlockchainSdk

class DetailsViewModel: ObservableObject {
    // MARK: - Dependencies

    @Injected(\.cardsRepository) private var cardsRepository: CardsRepository

    // MARK: - View State

    @Published var error: AlertBinder?

    var canCreateBackup: Bool {
        config.hasFeature(.backup)
    }

    var canTwin: Bool {
        config.hasFeature(.twinning)
    }

    var shouldShowWC: Bool {
        !config.getFeatureAvailability(.walletConnect).isHidden
    }

    var cardTouURL: URL? {
        config.touURL
    }

    var applicationInfoFooter: String? {
        guard let appName = InfoDictionaryUtils.appName.value,
              let version = InfoDictionaryUtils.version.value,
              let bundleVersion = InfoDictionaryUtils.bundleVersion.value else {
            return nil
        }

        return String(
            format: "%@ %@ (%@)",
            arguments: [appName, version, bundleVersion]
        )
    }

    var isMultiWallet: Bool {
        config.hasFeature(.multiCurrency)
    }

    // MARK: - Private

    private let cardId: String
    private let config: UserWalletConfig
    private let detailsInputMaintainer: DetailsInputMaintainer
    private unowned let coordinator: DetailsRoutable
    
    private var bag = Set<AnyCancellable>()

    init(input: DetailsInput, coordinator: DetailsRoutable) {
        self.config = input.config
        self.cardId = input.cardId
        self.detailsInputMaintainer = input.detailsInputMaintainer
        self.coordinator = coordinator
    }
    
    deinit {
        print("DetailsViewModel deinit")
    }

    func prepareBackup() {
        Analytics.log(.buttonCreateBackup)
        if let input = detailsInputMaintainer.backupInput {
            self.openOnboarding(with: input)
        }
    }
}

// MARK: - Navigation

extension DetailsViewModel {
    func openOnboarding(with input: OnboardingInput) {
        Analytics.log(.backupScreenOpened)
        coordinator.openOnboardingModal(with: input)
    }

    func openMail() {
        Analytics.log(.buttonSendFeedback)
        let dataCollector = DetailsFeedbackDataCollector(
            walletModels: detailsInputMaintainer.walletModels,
            userWalletEmailData: config.emailData
        )

        coordinator.openMail(with: dataCollector,
                             recipient: config.emailConfig.subject,
                             emailType: .appFeedback(subject: config.emailConfig.subject))
    }

    func openWalletConnect() {
        let input = WalletConnectInput(config: config)
        coordinator.openWalletConnect(with: input)
    }

    func openCurrencySelection() {
        coordinator.openCurrencySelection()
    }

    func openDisclaimer() {
        coordinator.openDisclaimer()
    }

    func openCardTOU(url: URL) {
        coordinator.openCardTOU(url: url)
    }

    func openCardSettings() {
        Analytics.log(.buttonCardSettings)
        coordinator.openScanCardSettings()
    }

    func openAppSettings() {
        Analytics.log(.buttonAppSettings)
        coordinator.openAppSettings()
    }

    func openSupportChat() {
        Analytics.log(.buttonChat)
        let dataCollector = DetailsFeedbackDataCollector(
            walletModels: detailsInputMaintainer.walletModels,
            userWalletEmailData: config.emailData
        )

        coordinator.openSupportChat(cardId: cardId, dataCollector: dataCollector)
    }

    func openSocialNetwork(network: SocialNetwork) {
        guard let url = network.url else {
            return
        }

        Analytics.log(.buttonSocialNetwork)
        coordinator.openInSafari(url: url)
    }
}
