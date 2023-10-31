//
//  AnalyticsEvent.swift
//  Tangem
//
//  Created by Andrew Son on 24/10/22.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

extension Analytics {
    enum ParameterValue: String {
        case welcome
        case walletOnboarding = "wallet_onboarding"
        case on = "On"
        case off = "Off"
        case yes = "Yes"
        case no = "No"
        case full = "Full"
        case null = "Null"
        case empty = "Empty"
        case mainToken = "Main Token"
        case customToken = "Custom Token"
        case noRate = "No Rate"
        case blockchainError = "Blockchain Error"
        case multicurrency = "Multicurrency"
        case accessCode = "Access Code"
        case longTap = "Long tap"
        case passcode = "Passcode"
        case scanSourceWelcome = "Introduction"
        case scanSourceMain = "Main"
        case scanSourceAuth = "Sign In"
        case scanSourceMyWallets = "My Wallets"
        case scanSourceSettings = "Settings"

        case transactionSourceSend = "Send"
        case transactionSourceSwap = "Swap"
        case transactionSourceApprove = "Approve"
        case transactionSourceWalletConnect = "WalletConnect"
        case transactionSourceSell = "Sell"

        case transactionFeeFixed = "Fixed"
        case transactionFeeMin = "Min"
        case transactionFeeNormal = "Normal"
        case transactionFeeMax = "Max"

        case signInTypeCard = "Card"
        case signInTypeBiometrics = "Biometric"

        case walletCreationTypePrivateKey = "Private Key"
        case walletCreationTypeNewSeed = "New Seed"
        case walletCreationTypeSeedImport = "Seed Import"

        case enabled = "Enabled"
        case disabled = "Disabled"
        case reset = "Reset"
        case cancel = "Cancel"

        case errorCode = "Error Code"

        case oneTransactionApprove = "Transaction"
        case unlimitedApprove = "Unlimited"

        // destination address entered
        case destinationAddressSourceQrCode = "QRCode"
        case destinationAddressPasteButton = "PasteButton"
        case destinationAddressPastePopup = "PastePopup"

        case success = "Success"
        case fail = "Fail"

        // SelectedCurrency
        case selectedCurrencyToken = "Token"
        case selectedCurrencyApp = "App Currency"

        // Client Type
        case old = "Old"
        case new = "New"

        case sortTypeByBalance = "By Balance"
        case sortTypeManual = "Manually"

        case balance = "Balance"

        // MARK: - Actions

        case scan = "tap_scan_task"
        case sendTx = "send_transaction"
        case pushTx = "push_transaction"
        case walletConnectSign = "wallet_connect_personal_sign"
        case walletConnectTxSend = "wallet_connect_tx_sign"
        case readPinSettings = "read_pin_settings"
        case changeSecOptions = "change_sec_options"
        case createWallet = "create_wallet"
        case purgeWallet = "purge_wallet"
        case deriveKeys = "derive_keys"
        case preparePrimary = "prepare_primary"
        case readPrimary = "read_primary"
        case addbackup = "add_backup"
        case proceedBackup = "proceed_backup"

        static func toggleState(for boolean: Bool) -> ParameterValue {
            return boolean ? .on : .off
        }

        static func affirmativeOrNegative(for boolean: Bool) -> ParameterValue {
            return boolean ? .yes : .no
        }
    }
}
