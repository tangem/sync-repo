//
//  Analytics.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.03.2020.
//  Copyright © 2020 Smart Cash AG. All rights reserved.
//

import Foundation
#if !CLIP // TODO: remove
import FirebaseAnalytics
import FirebaseCrashlytics
import AppsFlyerLib
import BlockchainSdk
import Amplitude
#endif
import TangemSdk

// todo: singleton
class Analytics {
    static private var analyticsSystems: [Analytics.AnalyticSystem] = [.firebase, .appsflyer, .amplitude]
    static private var persistentParams: [ParameterKey: String] = [:]

    static func reset() {
        persistentParams = [:]
    }

    static func log(_ event: Event, params: [ParameterKey: String] = [:]) {
        for system in analyticsSystems {
            switch system {
            case .appsflyer, .firebase:
                log(event: event, with: params)
            case .amplitude:
                logAmplitude(event: event, params: params)
            }
        }
    }

    static func logScan(card: Card, config: UserWalletConfig) {
        persistentParams[.batchId] = card.batchId

        log(event: .cardIsScanned, with: collectCardData(card))

        if DemoUtil().isDemoCard(cardId: card.cardId) {
            log(event: .demoActivated, with: [.cardId: card.cardId])
        }
    }

    static func logTx(blockchainName: String?, isPushed: Bool = false) {
        let event: Event = isPushed ? .transactionIsPushed : .transactionIsSent
        let params = [ParameterKey.blockchain: blockchainName ?? ""]
        log(event, params: params)
    }

    static func logCardSdkError(_ error: TangemSdkError, for action: Action, parameters: [ParameterKey: String] = [:]) {
        #if !CLIP
        if case .userCancelled = error { return }

        var params = parameters
        params[.action] = action.rawValue
        params[.errorKey] = String(describing: error)

        let nsError = NSError(domain: "Tangem SDK Error #\(error.code)", code: error.code, userInfo: params.firebaseParams)
        Crashlytics.crashlytics().record(error: nsError)
        #endif
    }

    static func logCardSdkError(_ error: TangemSdkError, for action: Action, card: Card, parameters: [ParameterKey: String] = [:]) {
        logCardSdkError(error, for: action, parameters: collectCardData(card, additionalParams: parameters))
    }

    static func log(error: Error) {
        #if !CLIP
        if case .userCancelled = error.toTangemSdkError() {
            return
        }

        if let detailedDescription = (error as? DetailedError)?.detailedDescription {
            var params = [ParameterKey: String]()
            params[.errorDescription] = detailedDescription
            let nsError = NSError(domain: "DetailedError",
                                  code: 1,
                                  userInfo: params.firebaseParams)
            Crashlytics.crashlytics().record(error: nsError)
        } else {
            Crashlytics.crashlytics().record(error: error)
        }

        #endif
    }

    #if !CLIP
    static func logWcEvent(_ event: WalletConnectEvent) {
        var params = [ParameterKey: String]()
        let firEvent: Event
        switch event {
        case let .error(error, action):
            if let action = action {
                params[.walletConnectAction] = action.rawValue
            }
            params[.errorDescription] = error.localizedDescription
            let nsError = NSError(domain: "WalletConnect Error for: \(action?.rawValue ?? "WC Service error")",
                                  code: 0,
                                  userInfo: params.firebaseParams)
            Crashlytics.crashlytics().record(error: nsError)
            return
        case .action(let action):
            params[.walletConnectAction] = action.rawValue
            firEvent = .wcSuccessResponse
        case .invalidRequest(let json):
            params[.walletConnectRequest] = json
            firEvent = .wcInvalidRequest
        case .session(let state, let url):
            switch state {
            case .connect:
                firEvent = .wcNewSession
            case .disconnect:
                firEvent = .wcSessionDisconnected
            }
            params[.walletConnectDappUrl] = url.absoluteString
        }

        log(firEvent, params: params)
    }
    #endif

    #if !CLIP
    static func logShopifyOrder(_ order: Order) {
        var appsFlyerDiscountParams: [String: Any] = [:]
        var firebaseDiscountParams: [String: Any] = [:]

        if let discountCode = order.discount?.code {
            appsFlyerDiscountParams[AFEventParamCouponCode] = discountCode
            firebaseDiscountParams[AnalyticsParameterCoupon] = discountCode
        }

        let sku = order.lineItems.first?.sku ?? "unknown"

        AppsFlyerLib.shared().logEvent(AFEventPurchase, withValues: appsFlyerDiscountParams.merging([
            AFEventParamContentId: sku,
            AFEventParamRevenue: order.total,
            AFEventParamCurrency: order.currencyCode,
        ], uniquingKeysWith: { $1 }))

        FirebaseAnalytics.Analytics.logEvent(AnalyticsEventPurchase, parameters: firebaseDiscountParams.merging([
            AnalyticsParameterItems: [
                [AnalyticsParameterItemID: sku],
            ],
            AnalyticsParameterValue: order.total,
            AnalyticsParameterCurrency: order.currencyCode,
        ], uniquingKeysWith: { $1 }))

        logAmplitude(event: .purchased, params: [.sku: sku,
                                                 .count: "\(order.lineItems.count)",
                                                 .amount: "\(order.total)\(order.currencyCode)"])
    }
    #endif

    private static func logAmplitude(event: Event, params: [ParameterKey: String] = [:]) {
        #if !CLIP
        let mergedParams = params.merging(persistentParams, uniquingKeysWith: { (current, _) in  current })
        let convertedParams = mergedParams.reduce(into: [:]) { $0[$1.key.rawValue] = $1.value }
        Amplitude.instance().logEvent(event.rawValue, withEventProperties: convertedParams)
        #endif
    }

    private static func log(event: Event, with params: [ParameterKey: String]? = nil) {
        #if !CLIP
        let key = event.rawValue

        let mergedParams = params?.merging(persistentParams, uniquingKeysWith: { (current, _) in  current })
        let values = mergedParams?.firebaseParams

        FirebaseAnalytics.Analytics.logEvent(key, parameters: values)
        AppsFlyerLib.shared().logEvent(key, withValues: values)
        #endif
    }

    private static func collectCardData(_ card: Card, additionalParams: [ParameterKey: String] = [:]) -> [ParameterKey: String] {
        var params = additionalParams
        params[.firmware] = card.firmwareVersion.stringValue
        return params
    }
}

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
        case activationScreenOpened = "[Onboarding / Top Up] Activation Screen Opened"
        case buttonBuyCrypto = "[Onboarding / Top Up] Button - Buy Crypto"
        case buttonShowTheWalletAddress = "[Onboarding / Top Up] Button - Show the Wallet Address"
        case enableBiometric = "[Onboarding / Biometric] Enable Biometric"
        case allowBiometricID = "[Onboarding / Biometric] Allow Face ID / Touch ID (System)"
        case twinningScreenOpened = "[Onboarding / Twins] Twinning Screen Opened"
        case twinSetupStarted = "[Onboarding / Twins] Twin Setup Started"
        case twinSetupFinished = "[Onboarding / Twins] Twin Setup Finished"
        case pinCodeSet = "[Onboarding] PIN code set"
        case buttonConnect = "[Onboarding] Button - Connect"
        case kycProgressScreenOpened = "[Onboarding] KYC started"
        case kycWaitingScreenOpened = "[Onboarding] KYC in progress"
        case kycRetryScreenOpened = "[Onboarding] KYC rejected"
        case claimScreenOpened = "[Onboarding] Claim screen opened"
        case buttonClaim = "[Onboarding] Button - Claim"
        case claimFinished = "[Onboarding] Claim was successfully "
        case screenOpened = "[Main Screen] Screen opened"
        case buttonScanCard = "[Main Screen] Button - Scan Card"
        case cardWasScanned = "[Main Screen] Card Was Scanned"
        case buttonMyWallets = "[Main Screen] Button - My Wallets"
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
        case walletTapped = "[My Wallets] Wallet Tapped"
        case buttonEditWalletTapped = "[My Wallets] Button - Edit Wallet Tapped"
        case buttonDeleteWalletTapped = "[My Wallets] Button - Delete Wallet Tapped"
        case buttonChat = "[Settings] Button - Chat"
        case buttonSendFeedback = "[Settings] Button - Send Feedback"
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
        case faceIDSwitcherChanged = "[Settings / App Settings] Face ID Switcher Changed"
        case saveAccessCodeSwitcherChanged = "[Settings / App Settings] Save Access Code Switcher Changed"
        case buttonEnableBiometricAuthentication = "[Settings / App Settings] Button - Enable Biometric Authentication"
        case newSessionEstablished = "[Wallet Connect] New Session Established"
        case sessionDisconnected = "[Wallet Connect] Session Disconnected"
        case requestSigned = "[Wallet Connect] Request Signed"
        case chatScreenOpened = "[Chat] Chat Screen Opened"
        case settingsScreenOpened = "[Settings] Settings Screen Opened"

        // MARK: -
        fileprivate static var nfcError: String {
            "nfc_error"
        }
    }

    enum Action: String {
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
    }

    enum ParameterKey: String {
        case blockchain = "blockchain"
        case batchId = "batch_id"
        case firmware = "firmware"
        case action = "action"
        case errorDescription = "error_description"
        case errorCode = "error_code"
        case newSecOption = "new_security_option"
        case errorKey = "Tangem SDK error key"
        case walletConnectAction = "wallet_connect_action"
        case walletConnectRequest = "wallet_connect_request"
        case walletConnectDappUrl = "wallet_connect_dapp_url"
        case currencyCode = "currency_code"
        case source = "source"
        case cardId = "cardId"
        case tokenName = "token_name"
        case type
        case currency = "Currency Type"
        case success
        case token = "Token"
        case mode = "Mode"
        case state = "State"
        case basicCurrency = "Currency"
        case batch = "Batch"
        case cardsCount = "Cards count"
        case sku = "SKU"
        case amount = "Amount"
        case count = "Count"
    }

    enum ParameterValue: String {
        case welcome
        case walletOnboarding = "wallet_onboarding"
    }

    enum AnalyticSystem {
        case firebase
        case amplitude
        case appsflyer
    }

    #if !CLIP
    enum WalletConnectEvent {
        enum SessionEvent {
            case disconnect
            case connect
        }

        case error(Error, WalletConnectAction?), session(SessionEvent, URL), action(WalletConnectAction), invalidRequest(json: String?)
    }
    #endif
}

fileprivate extension Dictionary where Key == Analytics.ParameterKey, Value == String {
    var firebaseParams: [String: Any] {
        var convertedParams = [String: Any]()
        forEach { convertedParams[$0.key.rawValue] = $0.value }
        return convertedParams
    }
}
