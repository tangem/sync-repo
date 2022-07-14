//
//  SecurityPrivacyViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 29.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine

class SecurityPrivacyViewModel: ObservableObject {
    // MARK: Dependecies
    private unowned let coordinator: SecurityPrivacyRoutable
    private let cardModel: CardViewModel?

    // MARK: ViewState

    @Published var isOnceOptionSecurityMode: Bool = false
    @Published var isChangeAccessCodeVisible: Bool = false
    @Published var securityModeTitle: String?
    @Published var isSaveCards: Bool = true
    @Published var isSaveAccessCodes: Bool = true
    @Published var alert: AlertBinder?

    // MARK: Properties

    private var bag: Set<AnyCancellable> = []
    private var shouldShowAlertOnDisableSaveAccessCodes: Bool = true

    init(
        inputModel: InputModel,
        coordinator: SecurityPrivacyRoutable
    ) {
        self.cardModel = inputModel.cardModel
        self.coordinator = coordinator

        securityModeTitle = inputModel.currentSecOption.title
        isOnceOptionSecurityMode = inputModel.availableSecOptions.count <= 1
        isChangeAccessCodeVisible = inputModel.currentSecOption == .accessCode

        bind()
    }
}

// MARK: - Private

private extension SecurityPrivacyViewModel {
    func bind() {
        $isSaveCards
            .dropFirst()
            .filter { !$0 }
            .sink(receiveValue: { [weak self] _ in
                self?.presentSaveWalletDeleteAlert()
            })
            .store(in: &bag)

        $isSaveAccessCodes
            .dropFirst()
            .filter { !$0 }
            .sink(receiveValue: { [weak self] _ in
                self?.presentChangeAccessCodeDeleteAlert()
            })
            .store(in: &bag)
    }

    func presentSaveWalletDeleteAlert() {
        let okButton = Alert.Button.destructive(Text("common_delete"), action: { [weak self] in
            self?.disableSaveWallet()
        })
        let cancelButton = Alert.Button.cancel(Text("common_cancel"), action: { [weak self] in
            self?.isSaveCards = true
        })

        let alert = Alert(
            title: Text("common_attention"),
            message: Text("security_and_privacy_off_saved_wallet_alert_message"),
            primaryButton: okButton,
            secondaryButton: cancelButton
        )

        self.alert = AlertBinder(alert: alert)
    }

    func presentChangeAccessCodeDeleteAlert() {
        guard shouldShowAlertOnDisableSaveAccessCodes else { return }
        let okButton = Alert.Button.destructive(Text("common_delete"), action: { [weak self] in
            self?.disableSaveAccessCodes()
        })

        let cancelButton = Alert.Button.cancel(Text("common_cancel"), action: { [weak self] in
            self?.isSaveAccessCodes = true
        })

        let alert = Alert(
            title: Text("common_attention"),
            message: Text("security_and_privacy_off_saved_access_code_alert_message"),
            primaryButton: okButton,
            secondaryButton: cancelButton
        )


        self.alert = AlertBinder(alert: alert)
    }

    func disableSaveWallet() {
        // TODO: Turn off save cards
        disableSaveAccessCodes()
    }

    func disableSaveAccessCodes() {
        // TODO: Turn off save access codes

        if isSaveAccessCodes {
            shouldShowAlertOnDisableSaveAccessCodes = false
            isSaveAccessCodes = false
            shouldShowAlertOnDisableSaveAccessCodes = true
        }
    }
}

// MARK: - View Output

extension SecurityPrivacyViewModel {
    func openChangeAccessCode() {
        coordinator.openChangeAccessCode()
    }

    func openChangeAccessMethod() {
        if let cardModel = cardModel {
            coordinator.openSecurityManagement(cardModel: cardModel)
        }
    }

    func openTokenSynchronization() {
        coordinator.openTokenSynchronization()
    }

    func openResetSavedCards() {
        coordinator.openResetSavedCards()
    }
}

extension SecurityPrivacyViewModel {
    struct InputModel {
        let currentSecOption: SecurityManagementOption
        let availableSecOptions: [SecurityManagementOption]
        let cardModel: CardViewModel?
    }
}
