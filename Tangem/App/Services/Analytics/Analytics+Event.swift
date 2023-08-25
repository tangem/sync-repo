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
        case signedIn = "[Basic] Signed in"
        case toppedUp = "[Basic] Topped up"
        case walletOpened = "[Basic] Wallet Opened"
        case balanceLoaded = "[Basic] Balance Loaded"
        case cardWasScanned = "[Basic] Card Was Scanned"
        case transactionSent = "[Basic] Transaction sent"
        case buttonTokensList = "[Introduction Process] Button - Tokens List"
        case buttonBuyCards = "[Introduction Process] Button - Buy Cards"
        case buttonRequestSupport = "[Introduction Process] Button - Request Support"
        case introductionProcessButtonScanCard = "[Introduction Process] Button - Scan Card"
        case introductionProcessOpened = "[Introduction Process] Introduction Process Screen Opened"
        case introductionProcessLearn = "[Introduction Process] Button - Learn"
        case promoBuy = "[Promo Screen] Button - Buy"
        case promoSuccessOpened = "[Promo Screen] Success Screen Opened"
        case shopScreenOpened = "[Shop] Shop Screen Opened"
        case purchased = "[Shop] Purchased"
        case redirected = "[Shop] Redirected"
        case signInScreenOpened = "[Sign In] Sing In Screen Opened"
        case buttonBiometricSignIn = "[Sign In] Button - Biometric Sign In"
        case buttonCardSignIn = "[Sign In] Button - Card Sign In"
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
        case backupResetCardNotification = "[Onboarding / Backup] Reset Card Notification"
        case activationScreenOpened = "[Onboarding / Top Up] Activation Screen Opened"
        case buttonBuyCrypto = "[Onboarding / Top Up] Button - Buy Crypto"
        case onboardingButtonShowTheWalletAddress = "[Onboarding / Top Up] Button - Show the Wallet Address"
        case onboardingEnableBiometric = "[Onboarding / Biometric] Enable Biometric"
        case allowBiometricID = "[Onboarding / Biometric] Allow Face ID / Touch ID (System)"
        case twinningScreenOpened = "[Onboarding / Twins] Twinning Screen Opened"
        case twinSetupStarted = "[Onboarding / Twins] Twin Setup Started"
        case twinSetupFinished = "[Onboarding / Twins] Twin Setup Finished"
        case onboardingButtonChat = "[Onboarding] Button - Chat"
        case mainScreenOpened = "[Main Screen] Screen Opened"
        case buttonScanCard = "[Main Screen] Button - Scan Card"
        case buttonMyWallets = "[Main Screen] Button - My Wallets"
        case mainEnableBiometric = "[Main Screen] Enable Biometric"
        case mainCurrencyChanged = "[Main Screen] Main Currency Changed"
        case noticeRateTheAppButtonTapped = "[Main Screen] Notice - Rate The App Button Tapped"
        case noticeBackupYourWalletTapped = "[Main Screen] Notice - Backup Your Wallet Tapped"
        case noticeScanYourCardTapped = "[Main Screen] Notice - Scan Your Card Tapped"
        case mainNoticeLearnAndEarn = "[Main Screen] Notice - Learn&Earn"
        case mainNoticeSuccessfulClaim = "[Main Screen] Notice - Successful Claim"
        case buttonManageTokens = "[Portfolio] Button - Manage Tokens"
        case tokenIsTapped = "[Portfolio] Token is Tapped"
        case mainRefreshed = "[Portfolio] Refreshed"
        case detailsScreenOpened = "[Details Screen] Details Screen Opened"
        case buttonRemoveToken = "[Token] Button - Remove Token"
        case buttonExplore = "[Token] Button - Explore"
        case buttonReload = "[Token] Button - Reload"
        case tokenButtonShowTheWalletAddress = "[Token] Button - Show the Wallet Address"
        case refreshed = "[Token] Refreshed"
        case buttonBuy = "[Token] Button - Buy"
        case buttonSell = "[Token] Button - Sell"
        case buttonExchange = "[Token] Button - Exchange"
        case buttonSend = "[Token] Button - Send"
        case buttonReceive = "[Token] Button - Receive"
        case buttonUnderstand = "[Token] Button - Understand"
        case tokenBought = "[Token] Token Bought"
        case receiveScreenOpened = "[Token / Receive] Receive Screen Opened"
        case buttonCopyAddress = "[Token / Receive] Button - Copy Address"
        case buttonShareAddress = "[Token / Receive] Button - Share Address"
        case sendScreenOpened = "[Token / Send] Send Screen Opened"
        case buttonPaste = "[Token / Send] Button - Paste"
        case buttonQRCode = "[Token / Send] Button - QR Code"
        case buttonSwapCurrency = "[Token / Send] Button - Swap Currency"
        case addressEntered = "[Token / Send] Address Entered"
        case selectedCurrency = "[Token / Send] Selected Currency"
        case topupScreenOpened = "[Token / Topup] Top Up Screen Opened"
        case p2PScreenOpened = "[Token / Topup] P2P Screen Opened"
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
        case requestHandled = "[Wallet Connect] Request Handled"
        case chatScreenOpened = "[Chat] Chat Screen Opened"
        case settingsScreenOpened = "[Settings] Settings Screen Opened"

        // MARK: - Referral program

        case referralScreenOpened = "[Referral Program] Referral Screen Opened"
        case referralButtonParticipate = "[Referral Program] Button - Participate"
        case referralButtonCopyCode = "[Referral Program] Button - Copy"
        case referralButtonShareCode = "[Referral Program] Button - Share"
        case referralButtonOpenTos = "[Referral Program] Link - TaC"

        // MARK: - Swapping

        case swapScreenOpenedSwap = "[Swap] Swap Screen Opened"
        case swapSendTokenBalanceClicked = "[Swap] Send Token Balance Clicked"
        case swapReceiveTokenClicked = "[Swap] Receive Token Clicked"
        case swapChooseTokenScreenOpened = "[Swap] Choose Token Screen Opened"
        case swapSearchedTokenClicked = "[Swap] Searched Token Clicked"
        case swapButtonSwap = "[Swap] Button - Swap"
        case swapButtonGivePermission = "[Swap] Button - Give permission"
        case swapButtonPermissionApprove = "[Swap] Button - Permission Approve"
        case swapButtonPermissionCancel = "[Swap] Button - Permission Cancel"
        case swapButtonPermitAndSwap = "[Swap] Button - Permit and Swap"
        case swapButtonSwipe = "[Swap] Button - Swipe"
        case swapSwapInProgressScreenOpened = "[Swap] Swap in Progress Screen Opened"

        // MARK: - Seed phrase

        case onboardingSeedButtonOtherCreateWalletOptions = "[Onboarding / Create Wallet] Button - Other Options"
        case onboarindgSeedButtonGenerateSeedPhrase = "[Onboarding / Seed Phrase] Button - Generate Seed Phrase"
        case onboardingSeedButtonImportWallet = "[Onboarding / Seed Phrase] Button - Import Wallet"
        case onboardingSeedButtonReadMore = "[Onboarding / Seed Phrase] Button - Read More"
        case onboardingSeedButtonImport = "[Onboarding / Seed Phrase] Button - Import"

        case onboardingSeedIntroScreenOpened = "[Onboarding / Seed Phrase] Seed Intro Screen Opened"
        case onboardingSeedGenerationScreenOpened = "[Onboarding / Seed Phrase] Seed Generation Screen Opened"
        case onboardingSeedCheckingScreenOpened = "[Onboarding / Seed Phrase] Seed Checking Screen Opened"
        case onboardingSeedImportScreenOpened = "[Onboarding / Seed Phrase] Import Seed Phrase Screen Opened"

        case onboardingSeedScreenCapture = "[Onboarding / Seed Phrase] Screen capture"

        // MARK: - Card settings

        case cardSettingsButtonAccessCodeRecovery = "[Settings / Card Settings] Button - Access Code Recovery"
        case cardSettingsAccessCodeRecoveryChanged = "[Settings / Card Settings] Access Code Recovery Changed"

        fileprivate static var nfcError: String {
            "nfc_error"
        }

        // MARK: - BlockchainSdk exceptions

        case blockchainSdkException = "[BlockchainSdk] Exception"
    }
}
