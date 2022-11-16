//
//  WelcomeViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 30.08.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI
import TangemSdk

class WelcomeViewModel: ObservableObject {
    @Injected(\.userWalletRepository) private var userWalletRepository: UserWalletRepository
    @Injected(\.backupServiceProvider) private var backupServiceProvider: BackupServiceProviding
    @Injected(\.failedScanTracker) var failedCardScanTracker: FailedScanTrackable
    @Injected(\.saletPayRegistratorProvider) private var saltPayRegistratorProvider: SaltPayRegistratorProviding

    @Published var showTroubleshootingView: Bool = false
    @Published var isScanningCard: Bool = false
    @Published var error: AlertBinder?
    @Published var discardAlert: ActionSheetBinder?
    @Published var storiesModel: StoriesViewModel = .init()

    // This screen seats on the navigation stack permanently. We should preserve the navigationBar state to fix the random hide/disappear events of navigationBar on iOS13 on other screens down the navigation hierarchy.
    @Published var navigationBarHidden: Bool = false
    @Published var showingAuthentication = false

    var shouldShowAuthenticationView: Bool {
        AppSettings.shared.saveUserWallets && !userWalletRepository.isEmpty && BiometricsUtil.isAvailable
    }

    var unlockWithBiometryLocalizationKey: LocalizedStringKey {
        switch BiometricAuthorizationUtils.biometryType {
        case .faceID:
            return "welcome_unlock_face_id"
        case .touchID:
            return "welcome_unlock_touch_id"
        case .none:
            return ""
        @unknown default:
            return ""
        }
    }

    private var storiesModelSubscription: AnyCancellable? = nil
    private var bag: Set<AnyCancellable> = []
    private var backupService: BackupService { backupServiceProvider.backupService }
    private let minimizedAppTimer = MinimizedAppTimer(interval: 60)

    private unowned let coordinator: WelcomeRoutable

    init(coordinator: WelcomeRoutable) {
        self.coordinator = coordinator
        userWalletRepository.delegate = self
        self.storiesModelSubscription = storiesModel.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.objectWillChange.send()
            })

        bind()
    }

    func bind() {
        minimizedAppTimer
            .timer
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.lock()
            }
            .store(in: &bag)
    }

    func scanCard() {
        isScanningCard = true
        Analytics.log(.buttonScanCard)
        var subscription: AnyCancellable? = nil

        subscription = userWalletRepository.scanPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("Failed to scan card: \(error)")
                    self?.isScanningCard = false
                    self?.failedCardScanTracker.recordFailure()

                    if let salpayError = error as? SaltPayRegistratorError {
                        self?.error = salpayError.alertBinder
                        return
                    }

                    if self?.failedCardScanTracker.shouldDisplayAlert ?? false {
                        self?.showTroubleshootingView = true
                    } else {
                        switch error.toTangemSdkError() {
                        case .unknownError, .cardVerificationFailed:
                            self?.error = error.alertBinder
                        default:
                            break
                        }
                    }
                }
                subscription.map { _ = self?.bag.remove($0) }
            } receiveValue: { [weak self] cardModel in
                self?.failedCardScanTracker.resetCounter()
                Analytics.log(.cardWasScanned)
                DispatchQueue.main.async {
                    self?.processScannedCard(cardModel, isWithAnimation: true)
                }
            }

        subscription?.store(in: &bag)
    }

    func unlockWithBiometry() {
        Analytics.log(.buttonBiometricSignIn)

        showingAuthentication = true
        userWalletRepository.unlock(with: .biometry, completion: self.didFinishUnlocking)
    }

    func unlockWithCard() {
        Analytics.log(.buttonCardSignIn)
        userWalletRepository.unlock(with: .card(userWallet: nil), completion: self.didFinishUnlocking)
    }

    func tryAgain() {
        scanCard()
    }

    func requestSupport() {
        Analytics.log(.buttonRequestSupport)
        failedCardScanTracker.resetCounter()
        openMail()
    }

    func orderCard() {
        openShop()
        Analytics.log(.getACard, params: [.source: Analytics.ParameterValue.welcome.rawValue])
        Analytics.log(.buttonBuyCards)
    }

    func onAppear() {
        navigationBarHidden = true
        Analytics.log(.introductionProcessOpened)
        showInteruptedBackupAlertIfNeeded()
    }

    func onDissappear() {
        navigationBarHidden = false
    }

    private func scanCardInternal(_ completion: @escaping (CardViewModel) -> Void) {
        isScanningCard = true
        var subscription: AnyCancellable? = nil

        subscription = userWalletRepository.scanPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    print("Failed to scan card: \(error)")
                    self?.isScanningCard = false
                    self?.failedCardScanTracker.recordFailure()

                    if self?.failedCardScanTracker.shouldDisplayAlert ?? false {
                        self?.showTroubleshootingView = true
                    } else {
                        switch error.toTangemSdkError() {
                        case .unknownError, .cardVerificationFailed:
                            self?.error = error.alertBinder
                        default:
                            break
                        }
                    }
                }
                subscription.map { _ = self?.bag.remove($0) }
            } receiveValue: { [weak self] cardModel in
                guard let self = self else { return }

                self.failedCardScanTracker.resetCounter()
                Analytics.log(.cardWasScanned)

                completion(cardModel)
            }

        subscription?.store(in: &bag)
    }

    private func processScannedCard(_ cardModel: CardViewModel, isWithAnimation: Bool) {
        let input = cardModel.onboardingInput
        self.isScanningCard = false

        if input.steps.needOnboarding {
            cardModel.userWalletModel?.updateAndReloadWalletModels()
            openOnboarding(with: input)
        } else {
            openMain(with: input)
        }
    }

    private func didFinishUnlocking(_ result: Result<Void, Error>) {
        if case .failure(let error) = result {
            print("Failed to unlock user wallets: \(error)")
            return
        }

        guard let model = userWalletRepository.selectedModel else { return }
        userWalletRepository.didSwitch(to: model)
        coordinator.openMain(with: model)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.showingAuthentication = false
        }
    }

    private func lock() {
        userWalletRepository.lock()
        showingAuthentication = true
        coordinator.openUnlockScreen()
    }
}

// MARK: - Navigation
extension WelcomeViewModel {
    func openInterruptedBackup(with input: OnboardingInput) {
        coordinator.openOnboardingModal(with: input)
    }

    func openMail() {
        coordinator.openMail(with: failedCardScanTracker, recipient: EmailConfig.default.recipient)
    }

    func openTokensList() {
        Analytics.log(.buttonTokensList)
        coordinator.openTokensList()
    }

    func openShop() {
        coordinator.openShop()
    }

    func openOnboarding(with input: OnboardingInput) {
        coordinator.openOnboarding(with: input)
    }

    func openMain(with input: OnboardingInput) {
        if let card = input.cardInput.cardModel {
            coordinator.openMain(with: card)
        }
    }
}

// MARK: - Resume interrupted backup
private extension WelcomeViewModel {
    func showInteruptedBackupAlertIfNeeded() {
        guard backupService.hasIncompletedBackup, !backupService.hasInterruptedSaltPayBackup else { return }

        let alert = Alert(title: Text("common_warning"),
                          message: Text("welcome_interrupted_backup_alert_message"),
                          primaryButton: .default(Text("welcome_interrupted_backup_alert_resume"), action: continueIncompletedBackup),
                          secondaryButton: .destructive(Text("welcome_interrupted_backup_alert_discard"), action: showExtraDiscardAlert))

        self.error = AlertBinder(alert: alert)
    }

    func showExtraDiscardAlert() {
        let buttonResume: ActionSheet.Button = .cancel(Text("welcome_interrupted_backup_discard_resume"), action: continueIncompletedBackup)
        let buttonDiscard: ActionSheet.Button = .destructive(Text("welcome_interrupted_backup_discard_discard"), action: backupService.discardIncompletedBackup)
        let sheet = ActionSheet(title: Text("welcome_interrupted_backup_discard_title"),
                                message: Text("welcome_interrupted_backup_discard_message"),
                                buttons: [buttonDiscard, buttonResume])

        DispatchQueue.main.async {
            self.discardAlert = ActionSheetBinder(sheet: sheet)
        }
    }

    func continueIncompletedBackup() {
        guard let primaryCardId = backupService.primaryCard?.cardId else {
            return
        }

        let input = OnboardingInput(steps: .wallet(WalletOnboardingStep.resumeBackupSteps),
                                    cardInput: .cardId(primaryCardId),
                                    welcomeStep: nil,
                                    twinData: nil,
                                    currentStepIndex: 0,
                                    isStandalone: true)

        self.openInterruptedBackup(with: input)
    }
}

extension WelcomeViewModel: UserWalletRepositoryDelegate {
    func showTOS(at url: URL, _ completion: @escaping (Bool) -> Void) {
        coordinator.openDisclaimer(at: url, completion)
    }
}

extension WelcomeViewModel: WelcomeViewLifecycleListener {
    func resignActve() {
        storiesModel.resignActve()
    }

    func becomeActive() {
        storiesModel.becomeActive()
    }
}
