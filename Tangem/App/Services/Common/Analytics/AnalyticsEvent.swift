//
//  AnalyticsEvent.swift
//  Tangem
//
//  Created by Andrew Son on 24/10/22.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

extension Analytics {
    enum Event: String {
        case cardIsScanned = "card_is_scanned"
        case transactionIsSent = "transaction_is_sent"
        case transactionIsPushed = "transaction_is_pushed"
        case readyToScan = "ready_to_scan"
        case displayRateAppWarning = "rate_app_warning_displayed"
        case negativeRateAppFeedback = "negative_rate_app_feedback"
        case positiveRateAppFeedback = "positive_rate_app_feedback"
        case dismissRateAppWarning = "dismiss_rate_app_warning"
        case wcSuccessResponse = "wallet_connect_success_response"
        case wcInvalidRequest = "wallet_connect_invalid_request"
        case wcNewSession = "wallet_connect_new_session"
        case wcSessionDisconnected = "wallet_connect_session_disconnected"
        case userBoughtCrypto = "user_bought_crypto"
        case userSoldCrypto = "user_sold_crypto"
        case getACard = "get_card"
        case demoActivated = "demo_mode_activated"

        // MARK: - Amplitude

        case signedIn = "[Basic] Signed in"
        case toppedUp = "[Basic] Topped up"
        case buttonTokensList = "[Introduction Process] Button - Tokens List"
        case buttonBuyCards = "[Introduction Process] Button - Buy Cards"
        case buttonRequestSupport = "[Introduction Process] Button - Request Support"
        case introductionProcessButtonScanCard = "[Introduction Process] Button - Scan Card"
        case introductionProcessCardWasScanned = "[Introduction Process] Card Was Scanned"
        case introductionProcessOpened = "[Introduction Process] Introduction Process Screen Opened"
        case shopScreenOpened = "[Shop] Shop Screen Opened"
        case purchased = "[Shop] Purchased"
        case redirected = "[Shop] Redirected"
        case signInScreenOpened = "[Sign In] Sing In Screen Opened"
        case buttonBiometricSignIn = "[Sign In] Button - Biometric Sign In"
        case buttonCardSignIn = "[Sign In] Button - Card Sign In"
        case signInCardWasScanned = "[Sign In] Card Was Scanned"
        case onboardingStarted = "[Onboarding] Onboarding Started"
        case onboardingFinished = "[Onboarding] Onboarding Finished"
        case createWalletScreenOpened = "[Onboarding / Create Wallet] Create Wallet Screen Opened"
        case buttonCreateWallet = "[Onboarding / Create Wallet] Button - Create Wallet"
        case walletCreatedSuccessfully = "[Onboarding / Create Wallet] Wallet Created Successfully"
        case backupScreenOpened = "[Onboarding / Backup] Backup Screen Opened"
        case backupStarted = "[Onboarding / Backup] Backup Started"
        case backupSkipped = "[Onboarding / Backup] Backup Skipped"
        case settingAccessCodeStarted = "[Onboarding / Backup] Setting Access Code Started"
        case accessCodeEntered = "[Onboarding / Backup] Access Code Entered"
        case accessCodeReEntered = "[Onboarding / Backup] Access Code Re-entered"
        case backupFinished = "[Onboarding / Backup] Backup Finished"
        case activationScreenOpened = "[Onboarding / Top Up] Activation Screen Opened"
        case buttonBuyCrypto = "[Onboarding / Top Up] Button - Buy Crypto"
        case onboardingButtonShowTheWalletAddress = "[Onboarding / Top Up] Button - Show the Wallet Address"
        case onboardingEnableBiometric = "[Onboarding / Biometric] Enable Biometric"
        case allowBiometricID = "[Onboarding / Biometric] Allow Face ID / Touch ID (System)"
        case twinningScreenOpened = "[Onboarding / Twins] Twinning Screen Opened"
        case twinSetupStarted = "[Onboarding / Twins] Twin Setup Started"
        case twinSetupFinished = "[Onboarding / Twins] Twin Setup Finished"
        case pinCodeSet = "[Onboarding] PIN code set"
        case buttonConnect = "[Onboarding] Button - Connect"
        case onboardingButtonChat = "[Onboarding] Button - Chat"
        case kycProgressScreenOpened = "[Onboarding] KYC started"
        case kycWaitingScreenOpened = "[Onboarding] KYC in progress"
        case kycRetryScreenOpened = "[Onboarding] KYC rejected"
        case claimScreenOpened = "[Onboarding] Claim screen opened"
        case buttonClaim = "[Onboarding] Button - Claim"
        case claimFinished = "[Onboarding] Claim was successfully "
        case screenOpened = "[Main Screen] Screen opened"
        case buttonScanCard = "[Main Screen] Button - Scan Card"
        case mainCardWasScanned = "[Main Screen] Card Was Scanned"
        case buttonMyWallets = "[Main Screen] Button - My Wallets"
        case mainEnableBiometric = "[Main Screen] Enable Biometric"
        case mainCurrencyChanged = "[Main Screen] Main Currency Changed"
        case noticeRateTheAppButtonTapped = "[Main Screen] Notice - Rate The App Button Tapped"
        case noticeBackupYourWalletTapped = "[Main Screen] Notice - Backup Your Wallet Tapped"
        case noticeScanYourCardTapped = "[Main Screen] Notice - Scan Your Card Tapped"
        case buttonManageTokens = "[Portfolio] Button - Manage Tokens"
        case tokenIsTapped = "[Portfolio] Token is Tapped"
        case mainRefreshed = "[Portfolio] Refreshed"
        case detailsScreenOpened = "[Details Screen] Details Screen Opened"
        case buttonRemoveToken = "[Token] Button - Remove Token"
        case buttonExplore = "[Token] Button - Explore"
        case tokenButtonShowTheWalletAddress = "[Token] Button - Show the Wallet Address"
        case refreshed = "[Token] Refreshed"
        case buttonBuy = "[Token] Button - Buy"
        case buttonSell = "[Token] Button - Sell"
        case buttonExchange = "[Token] Button - Exchange"
        case buttonSend = "[Token] Button - Send"
        case receiveScreenOpened = "[Token / Receive] Receive Screen Opened"
        case buttonCopyAddress = "[Token / Receive] Button - Copy Address"
        case buttonShareAddress = "[Token / Receive] Button - Share Address"
        case sendScreenOpened = "[Token / Send] Send Screen Opened"
        case buttonPaste = "[Token / Send] Button - Paste"
        case buttonQRCode = "[Token / Send] Button - QR Code"
        case buttonSwapCurrency = "[Token / Send] Button - Swap Currency"
        case transactionSent = "[Token / Send] Transaction Sent"
        case topUpScreenOpened = "[Token / TopUp] Top Up Screen Opened"
        case p2PScreenOpened = "[Token / TopUp] P2P Screen Opened"
        case withdrawScreenOpened = "[Token / Withdraw] Withdraw Screen Opened"
        case manageTokensScreenOpened = "[Manage Tokens] Manage Tokens Screen Opened"
        case tokenSearched = "[Manage Tokens] Token Searched"
        case tokenSwitcherChanged = "[Manage Tokens] Token Switcher Changed"
        case buttonSaveChanges = "[Manage Tokens] Button - Save Changes"
        case buttonCustomToken = "[Manage Tokens] Button - Custom Token"
        case customTokenScreenOpened = "[Manage Tokens] Custom Token Screen Opened"
        case customTokenWasAdded = "[Manage Tokens] Custom Token Was Added"
        case myWalletsScreenOpened = "[My Wallets] My Wallets Screen Opened"
        case buttonScanNewCard = "[My Wallets] Button - Scan New Card"
        case myWalletsCardWasScanned = "[My Wallets] Card Was Scanned"
        case buttonUnlockAllWithFaceID = "[My Wallets] Button - Unlock all with Face ID"
        case walletUnlockTapped = "[My Wallets] Button - Wallet Unlock Tapped"
        case buttonEditWalletTapped = "[My Wallets] Button - Edit Wallet Tapped"
        case buttonDeleteWalletTapped = "[My Wallets] Button - Delete Wallet Tapped"
        case settingsButtonChat = "[Settings] Button - Chat"
        case buttonSendFeedback = "[Settings] Button - Send Feedback"
        case buttonWalletConnect = "[Settings] Button - Wallet Connect"
        case buttonStartWalletConnectSession = "[Settings] Button - Start Wallet Connect Session"
        case buttonStopWalletConnectSession = "[Settings] Button - Stop Wallet Connect Session"
        case buttonCardSettings = "[Settings] Button - Card Settings"
        case buttonAppSettings = "[Settings] Button - App Settings"
        case buttonCreateBackup = "[Settings] Button - Create Backup"
        case buttonSocialNetwork = "[Settings] Button - Social Network"
        case buttonFactoryReset = "[Settings / Card Settings] Button - Factory Reset"
        case factoryResetFinished = "[Settings / Card Settings] Factory Reset Finished"
        case buttonChangeUserCode = "[Settings / Card Settings] Button - Change User Code"
        case userCodeChanged = "[Settings / Card Settings] User Code Changed"
        case buttonChangeSecurityMode = "[Settings / Card Settings] Button - Change Security Mode"
        case securityModeChanged = "[Settings / Card Settings] Security Mode Changed"
        case saveUserWalletSwitcherChanged = "[Settings / App Settings] Save Wallet Switcher Changed"
        case saveAccessCodeSwitcherChanged = "[Settings / App Settings] Save Access Code Switcher Changed"
        case buttonEnableBiometricAuthentication = "[Settings / App Settings] Button - Enable Biometric Authentication"
        case walletConnectScreenOpened = "[Wallet Connect] WC Screen Opened"
        case newSessionEstablished = "[Wallet Connect] New Session Established"
        case sessionDisconnected = "[Wallet Connect] Session Disconnected"
        case requestSigned = "[Wallet Connect] Request Signed"
        case chatScreenOpened = "[Chat] Chat Screen Opened"
        case settingsScreenOpened = "[Settings] Settings Screen Opened"

        // MARK: - Referral program

        case referralScreenOpened = "[Referral Program] Referral Screen Opened"
        case referralButtonParticipate = "[Referral Program] Button - Participate"
        case referralButtonCopyCode = "[Referral Program] Button - Copy"
        case referralButtonShareCode = "[Referral Program] Button - Share"
        case referralButtonOpenTos = "[Referral Program] Link - TaC"

        // MARK: -

        fileprivate static var nfcError: String {
            "nfc_error"
        }
    }
}
