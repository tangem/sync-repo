// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import SwiftUI

// MARK: - Strings

public enum L10n {
  /// Do you want to buy or sell crypto?
  public static let actionSheetTradeHint = LocalizedString(lookupKey: "action_sheet_trade_hint")
  /// Add custom token
  public static let addCustomTokenTitle = LocalizedString(lookupKey: "add_custom_token_title")
  /// Manage tokens
  public static let addTokensTitle = LocalizedString(lookupKey: "add_tokens_title")
  /// Send only %@ (%@) to this address. Sending any other currency will result in its irreversible loss.
  public static func addressQrCodeMessageFormat(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "address_qr_code_message_format", String(describing: p1), String(describing: p2))
  }
  /// Send only %@ (%@) from %@ network to this address. Sending any other currency will result in its irreversible loss.
  public static func addressQrCodeMessageTokenFormat(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "address_qr_code_message_token_format", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Thank you for your feedback
  public static let alertAppFeedbackSentMessage = LocalizedString(lookupKey: "alert_app_feedback_sent_message")
  /// Sent successfully
  public static let alertAppFeedbackSentTitle = LocalizedString(lookupKey: "alert_app_feedback_sent_title")
  /// I understand
  public static let alertButtonIUnderstand = LocalizedString(lookupKey: "alert_button_i_understand")
  /// Request support
  public static let alertButtonRequestSupport = LocalizedString(lookupKey: "alert_button_request_support")
  /// Send feedback
  public static let alertButtonSendFeedback = LocalizedString(lookupKey: "alert_button_send_feedback")
  /// Try again
  public static let alertButtonTryAgain = LocalizedString(lookupKey: "alert_button_try_again")
  /// This card has been already topped up and signed transactions in the past. Consider immediate withdrawal of all funds if you have received this card from an untrusted source. If it's your card, there is nothing to worry about.
  public static let alertCardSignedTransactions = LocalizedString(lookupKey: "alert_card_signed_transactions")
  /// This feature is disabled in Demo mode
  public static let alertDemoFeatureDisabled = LocalizedString(lookupKey: "alert_demo_feature_disabled")
  /// You are currently running in Demo mode. All funds are not real.
  public static let alertDemoMessage = LocalizedString(lookupKey: "alert_demo_message")
  /// The card you scanned is a development card. Don’t accept it as a payment.
  public static let alertDeveloperCard = LocalizedString(lookupKey: "alert_developer_card")
  /// Reason: %@
  public static func alertFailedToSendEmailMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "alert_failed_to_send_email_message", String(describing: p1))
  }
  /// Failed to send email
  public static let alertFailedToSendEmailTitle = LocalizedString(lookupKey: "alert_failed_to_send_email_title")
  /// Reason: %@. Do you want to request support?
  public static func alertFailedToSendTransactionMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "alert_failed_to_send_transaction_message", String(describing: p1))
  }
  /// Can't send a transaction
  public static let alertFailedToSendTransactionTitle = LocalizedString(lookupKey: "alert_failed_to_send_transaction_title")
  /// If you chose the wrong network during your crypto transfer from the exchange, this guide will help you recover your funds
  public static let alertFundsRestorationMessage = LocalizedString(lookupKey: "alert_funds_restoration_message")
  /// Note that tokens on different networks have different addresses. Double check that your address matches the network when you transfer funds.
  public static let alertManageTokensAddressesMessage = LocalizedString(lookupKey: "alert_manage_tokens_addresses_message")
  /// Tokens in Solana network are not supported by this card due to firmware limitation.
  public static let alertManageTokensUnsupportedMessage = LocalizedString(lookupKey: "alert_manage_tokens_unsupported_message")
  /// Thank your for your feedback. We will response as soon as possible
  public static let alertNegativeAppRateSentMessage = LocalizedString(lookupKey: "alert_negative_app_rate_sent_message")
  /// Your suggestions were sent
  public static let alertNegativeAppRateSentTitle = LocalizedString(lookupKey: "alert_negative_app_rate_sent_title")
  /// Funds from Tangem cards issued before September 2019 cannot be retrieved using an iPhone due to iOS restrictions. You must use an Android phone to retrieve funds. Cards released after September 2019 work correctly with both platforms.
  public static let alertOldCard = LocalizedString(lookupKey: "alert_old_card")
  /// You may experience NFC problems with some iPhone 7/7+ during some operations
  public static let alertOldDeviceThisCard = LocalizedString(lookupKey: "alert_old_device_this_card")
  /// This card is not a bearer note. We can’t currently match the signature count on the card with the information on the blockchain. This is normal but in rare cases can mean a previous holder is holding back an offline signature, which is a security concern.\nDo not accept this card as physical payment from someone you don’t trust.\nIt’s perfectly safe in all other respects.\nTangem is the only hardware wallet to offer signature count protection.
  public static let alertSignedHashesMessage = LocalizedString(lookupKey: "alert_signed_hashes_message")
  /// Please try to tap the card exactly as shown in the animation or request support.
  public static let alertTroubleshootingScanCardMessage = LocalizedString(lookupKey: "alert_troubleshooting_scan_card_message")
  /// Are you having difficulty scanning your card?
  public static let alertTroubleshootingScanCardTitle = LocalizedString(lookupKey: "alert_troubleshooting_scan_card_title")
  /// Card %d of %d
  public static func cardLabelNumberFormat(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "card_label_number_format", p1, p2)
  }
  /// Reset the card
  public static let cardOperationButtonTitleReset = LocalizedString(lookupKey: "card_operation_button_title_reset")
  /// Accept
  public static let commonAccept = LocalizedString(lookupKey: "common_accept")
  /// Attention
  public static let commonAttention = LocalizedString(lookupKey: "common_attention")
  /// Back
  public static let commonBack = LocalizedString(lookupKey: "common_back")
  /// Settings
  public static let commonCameraAlertButtonSettings = LocalizedString(lookupKey: "common_camera_alert_button_settings")
  /// You have not given access to your camera, please adjust your privacy settings
  public static let commonCameraDeniedAlertMessage = LocalizedString(lookupKey: "common_camera_denied_alert_message")
  /// Camera access denied
  public static let commonCameraDeniedAlertTitle = LocalizedString(lookupKey: "common_camera_denied_alert_title")
  /// Cancel
  public static let commonCancel = LocalizedString(lookupKey: "common_cancel")
  /// Close
  public static let commonClose = LocalizedString(lookupKey: "common_close")
  /// Continue
  public static let commonContinue = LocalizedString(lookupKey: "common_continue")
  /// Copy
  public static let commonCopy = LocalizedString(lookupKey: "common_copy")
  /// Custom
  public static let commonCustom = LocalizedString(lookupKey: "common_custom")
  /// Disconnect
  public static let commonDisconnect = LocalizedString(lookupKey: "common_disconnect")
  /// Done
  public static let commonDone = LocalizedString(lookupKey: "common_done")
  /// Error
  public static let commonError = LocalizedString(lookupKey: "common_error")
  /// %@ explorer
  public static func commonExplorerFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "common_explorer_format", String(describing: p1))
  }
  /// No
  public static let commonNo = LocalizedString(lookupKey: "common_no")
  /// Notice
  public static let commonNotice = LocalizedString(lookupKey: "common_notice")
  /// OK
  public static let commonOk = LocalizedString(lookupKey: "common_ok")
  /// Primary Card
  public static let commonOriginCard = LocalizedString(lookupKey: "common_origin_card")
  /// Push
  public static let commonPush = LocalizedString(lookupKey: "common_push")
  /// Reject
  public static let commonReject = LocalizedString(lookupKey: "common_reject")
  /// Save changes
  public static let commonSaveChanges = LocalizedString(lookupKey: "common_save_changes")
  /// Search
  public static let commonSearch = LocalizedString(lookupKey: "common_search")
  /// Select action
  public static let commonSelectAction = LocalizedString(lookupKey: "common_select_action")
  /// The server is not available, please try again later
  public static let commonServerUnavailable = LocalizedString(lookupKey: "common_server_unavailable")
  /// Share
  public static let commonShare = LocalizedString(lookupKey: "common_share")
  /// Sign
  public static let commonSign = LocalizedString(lookupKey: "common_sign")
  /// Sign and send
  public static let commonSignAndSend = LocalizedString(lookupKey: "common_sign_and_send")
  /// Start
  public static let commonStart = LocalizedString(lookupKey: "common_start")
  /// Submit
  public static let commonSubmit = LocalizedString(lookupKey: "common_submit")
  /// Success
  public static let commonSuccess = LocalizedString(lookupKey: "common_success")
  /// Warning
  public static let commonWarning = LocalizedString(lookupKey: "common_warning")
  /// Contract address copied!
  public static let contractAddressCopiedMessage = LocalizedString(lookupKey: "contract_address_copied_message")
  /// Available networks
  public static let currencySubtitleExpanded = LocalizedString(lookupKey: "currency_subtitle_expanded")
  /// Add token
  public static let customTokenAddToken = LocalizedString(lookupKey: "custom_token_add_token")
  /// Contract address
  public static let customTokenContractAddressInputTitle = LocalizedString(lookupKey: "custom_token_contract_address_input_title")
  /// Please fill in all the fields
  public static let customTokenCreationErrorEmptyFields = LocalizedString(lookupKey: "custom_token_creation_error_empty_fields")
  /// Contract address is invalid
  public static let customTokenCreationErrorInvalidContractAddress = LocalizedString(lookupKey: "custom_token_creation_error_invalid_contract_address")
  /// Derivation path is invalid
  public static let customTokenCreationErrorInvalidDerivationPath = LocalizedString(lookupKey: "custom_token_creation_error_invalid_derivation_path")
  /// Please select the network
  public static let customTokenCreationErrorNetworkNotSelected = LocalizedString(lookupKey: "custom_token_creation_error_network_not_selected")
  /// Decimal number must be a valid integer, no higher than %d
  public static func customTokenCreationErrorWrongDecimals(_ p1: Int) -> String {
    return L10n.tr("Localizable", "custom_token_creation_error_wrong_decimals", p1)
  }
  /// Decimals
  public static let customTokenDecimalsInputTitle = LocalizedString(lookupKey: "custom_token_decimals_input_title")
  /// Default
  public static let customTokenDerivationPathDefault = LocalizedString(lookupKey: "custom_token_derivation_path_default")
  /// BIP44 coin type
  public static let customTokenDerivationPathInputTitle = LocalizedString(lookupKey: "custom_token_derivation_path_input_title")
  /// E.g. USD Coin
  public static let customTokenNameInputPlaceholder = LocalizedString(lookupKey: "custom_token_name_input_placeholder")
  /// Name
  public static let customTokenNameInputTitle = LocalizedString(lookupKey: "custom_token_name_input_title")
  /// Not selected
  public static let customTokenNetworkInputNotSelected = LocalizedString(lookupKey: "custom_token_network_input_not_selected")
  /// Network
  public static let customTokenNetworkInputTitle = LocalizedString(lookupKey: "custom_token_network_input_title")
  /// E.g. USDC
  public static let customTokenTokenSymbolInputPlaceholder = LocalizedString(lookupKey: "custom_token_token_symbol_input_placeholder")
  /// Token symbol
  public static let customTokenTokenSymbolInputTitle = LocalizedString(lookupKey: "custom_token_token_symbol_input_title")
  /// This token/network has already been added to your list
  public static let customTokenValidationErrorAlreadyAdded = LocalizedString(lookupKey: "custom_token_validation_error_already_added")
  /// Note that tokens can be created by anyone. Be aware of adding scam tokens, they can cost nothing.
  public static let customTokenValidationErrorNotFound = LocalizedString(lookupKey: "custom_token_validation_error_not_found")
  /// Active. Backup cards count: %d
  public static func detailsBackupStatusFormatActive(_ p1: Int) -> String {
    return L10n.tr("Localizable", "details_backup_status_format_active", p1)
  }
  /// Linked. Backup cards count: %d
  public static func detailsBackupStatusFormatLinked(_ p1: Int) -> String {
    return L10n.tr("Localizable", "details_backup_status_format_linked", p1)
  }
  /// No backup
  public static let detailsBackupStatusNoBackup = LocalizedString(lookupKey: "details_backup_status_no_backup")
  /// Access code
  public static let detailsManageSecurityAccessCode = LocalizedString(lookupKey: "details_manage_security_access_code")
  /// You will have to submit the correct access code before scanning the card
  public static let detailsManageSecurityAccessCodeDescription = LocalizedString(lookupKey: "details_manage_security_access_code_description")
  /// Long Tap
  public static let detailsManageSecurityLongTap = LocalizedString(lookupKey: "details_manage_security_long_tap")
  /// This mechanism protects against proximity attacks on a card. It will enforce a delay between reception and execution of a command. 
  public static let detailsManageSecurityLongTapDescription = LocalizedString(lookupKey: "details_manage_security_long_tap_description")
  /// Passcode
  public static let detailsManageSecurityPasscode = LocalizedString(lookupKey: "details_manage_security_passcode")
  /// Before execution any command entailing a change of the card state, you will have to enter the passcode.
  public static let detailsManageSecurityPasscodeDescription = LocalizedString(lookupKey: "details_manage_security_passcode_description")
  /// Manage Security
  public static let detailsManageSecurityTitle = LocalizedString(lookupKey: "details_manage_security_title")
  /// Your balance on this wallet is not zero, or you have unconfirmed transactions. Reset to factory settings not possible.
  public static let detailsNotificationEraseWalletNotPossible = LocalizedString(lookupKey: "details_notification_erase_wallet_not_possible")
  /// %@ hashes
  public static func detailsRowSubtitleSignedHashesFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "details_row_subtitle_signed_hashes_format", String(describing: p1))
  }
  /// Card terms of use
  public static let detailsRowTitleCardTou = LocalizedString(lookupKey: "details_row_title_card_tou")
  /// Card ID
  public static let detailsRowTitleCid = LocalizedString(lookupKey: "details_row_title_cid")
  /// Create backup
  public static let detailsRowTitleCreateBackup = LocalizedString(lookupKey: "details_row_title_create_backup")
  /// App currency
  public static let detailsRowTitleCurrency = LocalizedString(lookupKey: "details_row_title_currency")
  /// Issuer
  public static let detailsRowTitleIssuer = LocalizedString(lookupKey: "details_row_title_issuer")
  /// Manage Security
  public static let detailsRowTitleManageSecurity = LocalizedString(lookupKey: "details_row_title_manage_security")
  /// Reset to factory settings
  public static let detailsRowTitleResetFactorySettings = LocalizedString(lookupKey: "details_row_title_reset_factory_settings")
  /// This action is irreversible. If, after resetting the card, someone sends funds to it, then you will not be able to withdraw them.
  public static let detailsRowTitleResetFactorySettingsWarning = LocalizedString(lookupKey: "details_row_title_reset_factory_settings_warning")
  /// Send feedback
  public static let detailsRowTitleSendFeedback = LocalizedString(lookupKey: "details_row_title_send_feedback")
  /// Signed
  public static let detailsRowTitleSignedHashes = LocalizedString(lookupKey: "details_row_title_signed_hashes")
  /// Create wallet
  public static let detailsRowTitleTwinsCreate = LocalizedString(lookupKey: "details_row_title_twins_create")
  /// Re-create twin wallet
  public static let detailsRowTitleTwinsRecreate = LocalizedString(lookupKey: "details_row_title_twins_recreate")
  /// App
  public static let detailsSectionTitleApp = LocalizedString(lookupKey: "details_section_title_app")
  /// Card
  public static let detailsSectionTitleCard = LocalizedString(lookupKey: "details_section_title_card")
  /// If you forget the code, you will lose the ability to use the card. There is no way to recover or change your code if you lose it.
  public static let detailsSecurityManagementWarning = LocalizedString(lookupKey: "details_security_management_warning")
  /// Details
  public static let detailsTitle = LocalizedString(lookupKey: "details_title")
  /// The wallet creation procedure consists of three steps. You must complete it to the end, otherwise the cards will not be paired and you will have to start from the beginning.
  public static let detailsTwinsCreateWarning = LocalizedString(lookupKey: "details_twins_create_warning")
  /// Tap the card #%d
  public static func detailsTwinsRecreateButtonFormat(_ p1: Int) -> String {
    return L10n.tr("Localizable", "details_twins_recreate_button_format", p1)
  }
  /// Step %d
  public static func detailsTwinsRecreateStepFormat(_ p1: Int) -> String {
    return L10n.tr("Localizable", "details_twins_recreate_step_format", p1)
  }
  /// If the process of re-creating the wallet gets interrupted in any way, you’ll have to start over.
  public static let detailsTwinsRecreateSubtitle = LocalizedString(lookupKey: "details_twins_recreate_subtitle")
  /// Tap the #%d twin card
  public static func detailsTwinsRecreateTitleFormat(_ p1: Int) -> String {
    return L10n.tr("Localizable", "details_twins_recreate_title_format", p1)
  }
  /// Re-create wallet
  public static let detailsTwinsRecreateToolbar = LocalizedString(lookupKey: "details_twins_recreate_toolbar")
  /// This action is irreversible. You will not have access to the old wallet.\nThe wallet re-creation procedure consists of three steps. You must complete it to the end, otherwise you will have to start from the beginning.
  public static let detailsTwinsRecreateWarning = LocalizedString(lookupKey: "details_twins_recreate_warning")
  /// Legal Disclaimer\n\n1. Tangem application (Software)\n \nThe Software is intended for usage only with Tangem hardware wallets (Cards) via NFC interface. The Software DOES NOT:\n \na) Generate, store, transmit, or have access to private (secret) cryptographic keys to blockchain wallets holding digital assets, including crypto-currency.\n\nb) Generate, store, transmit, or have access to secret keys, passwords, passphrases, recovery phrases that can be used to restore or to copy private (secret) keys to blockchain wallets holding digital assets, including crypto-currency.\n\nc) Provide exchange, trading, investment services on behalf of Tangem AG.\n \n \n2. Risks related to the use of Software\n \nTangem will not be responsible for any losses, damages or claims arising from events falling within the scope of the following five categories:\n \na) Mistakes made by the user of any cryptocurrency-related software or service, e.g., forgotten passwords, payments sent to wrong addresses, and accidental deletion of blockchain wallets on Cards.\n\nb) Problems of Software and/or any blockchain- or cryptocurrency- related software or service, e.g., corrupted files, incorrectly constructed transactions, unsafe cryptographic libraries, malware.\n\nc) Technical failures in the hardware of the user, including Cards, of any cryptocurrency-related software or service, e.g., data loss due to a faulty or damaged storage device.\n\nd) Security problems experienced by the user of any cryptocurrency-related software or service, e.g., unauthorized access to users' wallets and/or accounts.\n\ne) Actions or inactions of third parties and/or events experienced by third parties, e.g., bankruptcy of service providers, information security attacks on service providers, and fraud conducted by third parties.\n \n\n3. Trading and Investment risks\n \nThere is considerable exposure to risk in any crypto-currency or other digital asset exchange transaction. Any transaction involving currencies involves risks including, but not limited to, the potential for changing economic conditions that may substantially affect the price or liquidity of a currency. Investments in crypto-currency exchange speculation may also be susceptible to sharp rises and falls as the relevant market values fluctuate. It is for this reason that when speculating in such markets it is advisable to use only risk capital.\n \n \n4. Electronic Trading Risks\n \nBefore you engage in transactions using an electronic system, you should carefully review the rules and regulations of the exchanges offering the system and/or listing the instruments you intend to trade. Online trading has inherent risk due to system response and access times that may vary due to market conditions, system performance, and other factors. You should understand these and additional risks before trading.\n \n\n5. Compliance with tax obligations\n \nThe users of the Software are solely responsible to determinate what, if any, taxes apply to their crypto-currency transactions. The owners of, or contributors to, the Software are NOT responsible for determining the taxes that apply to crypto-currency transactions.\n \n\n6. No warranties\n\nThe Software is provided on an "as is" basis without any warranties of any kind regarding the Software and/or any content, data, materials and/or services provided on the Software.\n \n\n7. Limitation of liability\n \nUnless otherwise required by law, in no event shall the owners of, or contributors to, the Software be liable for any damages of any kind, including, but not limited to, loss of use, loss of profits, or loss of data arising out of or in any way connected with the use of the Software. In no way are the owners of, or contributors to, the Software responsible for the actions, decisions, or other behavior taken or not taken by you in reliance upon the Software.\n \n \n8. Last amendment\n \nThis disclaimer was amended for the last time on October 1st, 2020.
  public static let disclaimerText = LocalizedString(lookupKey: "disclaimer_text")
  /// Terms of service
  public static let disclaimerTitle = LocalizedString(lookupKey: "disclaimer_title")
  /// Following information is optional. You can erase it if you don’t want to share it.
  public static let feedbackDataCollectionMessage = LocalizedString(lookupKey: "feedback_data_collection_message")
  /// Tell us what functions you are missing, and we will try to help you.
  public static let feedbackPrefaceRateNegative = LocalizedString(lookupKey: "feedback_preface_rate_negative")
  /// Please tell us what card do you have?
  public static let feedbackPrefaceScanFailed = LocalizedString(lookupKey: "feedback_preface_scan_failed")
  /// Hi support team,
  public static let feedbackPrefaceSupport = LocalizedString(lookupKey: "feedback_preface_support")
  /// Please tell us more about your issue. Every small detail can help.
  public static let feedbackPrefaceTxFailed = LocalizedString(lookupKey: "feedback_preface_tx_failed")
  /// Please tell us more about your issue. Every small detail can help.
  public static let feedbackPrefaceTxPushFailed = LocalizedString(lookupKey: "feedback_preface_tx_push_failed")
  /// My suggestions
  public static let feedbackSubjectRateNegative = LocalizedString(lookupKey: "feedback_subject_rate_negative")
  /// Can't scan a card
  public static let feedbackSubjectScanFailed = LocalizedString(lookupKey: "feedback_subject_scan_failed")
  /// Feedback
  public static let feedbackSubjectSupport = LocalizedString(lookupKey: "feedback_subject_support")
  /// Tangem feedback
  public static let feedbackSubjectSupportTangem = LocalizedString(lookupKey: "feedback_subject_support_tangem")
  /// Can't send a transaction
  public static let feedbackSubjectTxFailed = LocalizedString(lookupKey: "feedback_subject_tx_failed")
  /// Can't push a transaction
  public static let feedbackSubjectTxPushFailed = LocalizedString(lookupKey: "feedback_subject_tx_push_failed")
  /// Order
  public static let homeButtonOrder = LocalizedString(lookupKey: "home_button_order")
  /// Scan card
  public static let homeButtonScan = LocalizedString(lookupKey: "home_button_scan")
  /// Search tokens
  public static let homeButtonSearchTokens = LocalizedString(lookupKey: "home_button_search_tokens")
  /// To change the access code, connect your phone and the card exactly as it shown above
  public static let initialMessageChangeAccessCodeBody = LocalizedString(lookupKey: "initial_message_change_access_code_body")
  /// To change the passcode, connect your phone and the card exactly as it shown above
  public static let initialMessageChangePasscodeBody = LocalizedString(lookupKey: "initial_message_change_passcode_body")
  /// To create wallet, connect your phone and the card exactly as it shown above
  public static let initialMessageCreateWalletBody = LocalizedString(lookupKey: "initial_message_create_wallet_body")
  /// To reset to factory settings, connect your phone and the card exactly as it shown above
  public static let initialMessagePurgeWalletBody = LocalizedString(lookupKey: "initial_message_purge_wallet_body")
  /// To sign, connect your phone and the card exactly as it shown above
  public static let initialMessageSignBody = LocalizedString(lookupKey: "initial_message_sign_body")
  /// Please, set up an account to send email
  public static let mailErrorNoAccountsBody = LocalizedString(lookupKey: "mail_error_no_accounts_body")
  /// No Mail accounts
  public static let mailErrorNoAccountsTitle = LocalizedString(lookupKey: "mail_error_no_accounts_title")
  /// Manage tokens
  public static let mainManageTokensButton = LocalizedString(lookupKey: "main_manage_tokens_button")
  /// Total balance
  public static let mainPageBalance = LocalizedString(lookupKey: "main_page_balance")
  /// Access code is available only for cards with a backup.
  public static let manageSecurityAccessCodeDisclaimer = LocalizedString(lookupKey: "manage_security_access_code_disclaimer")
  /// The twin address was successfully created
  public static let notificationTwinsRecreateSuccess = LocalizedString(lookupKey: "notification_twins_recreate_success")
  /// You have to setup a single access code to protect all yor wallets.
  public static let onboardingAccessCodeFeature1Description = LocalizedString(lookupKey: "onboarding_access_code_feature_1_description")
  /// Protect
  public static let onboardingAccessCodeFeature1Title = LocalizedString(lookupKey: "onboarding_access_code_feature_1_title")
  /// You can set an individual access code on each card later.
  public static let onboardingAccessCodeFeature2Description = LocalizedString(lookupKey: "onboarding_access_code_feature_2_description")
  /// Personalize
  public static let onboardingAccessCodeFeature2Title = LocalizedString(lookupKey: "onboarding_access_code_feature_2_title")
  /// The access code can be restored with a linked card, don’t keep all cards at one place.
  public static let onboardingAccessCodeFeature3Description = LocalizedString(lookupKey: "onboarding_access_code_feature_3_description")
  /// Restore
  public static let onboardingAccessCodeFeature3Title = LocalizedString(lookupKey: "onboarding_access_code_feature_3_title")
  /// Choose any word, phrase, or number you want as your access code.
  public static let onboardingAccessCodeHint = LocalizedString(lookupKey: "onboarding_access_code_hint")
  /// Create Access Code
  public static let onboardingAccessCodeIntroTitle = LocalizedString(lookupKey: "onboarding_access_code_intro_title")
  /// Re-enter your Access Code
  public static let onboardingAccessCodeRepeatCodeTitle = LocalizedString(lookupKey: "onboarding_access_code_repeat_code_title")
  /// Access code must be at least 4 characters long
  public static let onboardingAccessCodeTooShort = LocalizedString(lookupKey: "onboarding_access_code_too_short")
  /// Entered access code didn't match initial access code
  public static let onboardingAccessCodesDoesntMatch = LocalizedString(lookupKey: "onboarding_access_codes_doesnt_match")
  /// I understand
  public static let onboardingAlertIUnderstand = LocalizedString(lookupKey: "onboarding_alert_i_understand")
  /// You’ve added one backup card. When backup process is finished you can’t add more backup cards. If you have one more card, add it in backup, otherwise you can buy it in shop. Do you like to continue backup process?
  public static let onboardingAlertMessageNotMaxBackupCardsAdded = LocalizedString(lookupKey: "onboarding_alert_message_not_max_backup_cards_added")
  /// iPhone 7/7+ is not able to create a backup for Tangem Wallet due to some system limitations. Please use another phone to perform this operation. All other functions work stably.
  public static let onboardingAlertMessageOldDevice = LocalizedString(lookupKey: "onboarding_alert_message_old_device")
  /// This action is irreversible. You will not have access to the old wallet.
  public static let onboardingAlertTwinsRecreateSubtitle = LocalizedString(lookupKey: "onboarding_alert_twins_recreate_subtitle")
  /// The backup process is partly complete. You can’t exit it now.
  public static let onboardingBackupExitWarning = LocalizedString(lookupKey: "onboarding_backup_exit_warning")
  /// BALANCE
  public static let onboardingBalance = LocalizedString(lookupKey: "onboarding_balance")
  /// Add a backup card
  public static let onboardingButtonAddBackupCard = LocalizedString(lookupKey: "onboarding_button_add_backup_card")
  /// Scan the card #%d
  public static func onboardingButtonBackupCard(_ p1: Int) -> String {
    return L10n.tr("Localizable", "onboarding_button_backup_card", p1)
  }
  /// Backup now
  public static let onboardingButtonBackupNow = LocalizedString(lookupKey: "onboarding_button_backup_now")
  /// Scan the primary card
  public static let onboardingButtonBackupOrigin = LocalizedString(lookupKey: "onboarding_button_backup_origin")
  /// Buy crypto
  public static let onboardingButtonBuyCrypto = LocalizedString(lookupKey: "onboarding_button_buy_crypto")
  /// Continue to my wallet
  public static let onboardingButtonContinueWallet = LocalizedString(lookupKey: "onboarding_button_continue_wallet")
  /// Create wallet
  public static let onboardingButtonCreateWallet = LocalizedString(lookupKey: "onboarding_button_create_wallet")
  /// Finalize the backup process
  public static let onboardingButtonFinalizeBackup = LocalizedString(lookupKey: "onboarding_button_finalize_backup")
  /// How it works?
  public static let onboardingButtonHowItWorks = LocalizedString(lookupKey: "onboarding_button_how_it_works")
  /// Receive crypto
  public static let onboardingButtonReceiveCrypto = LocalizedString(lookupKey: "onboarding_button_receive_crypto")
  /// Scan primary card
  public static let onboardingButtonScanOriginCard = LocalizedString(lookupKey: "onboarding_button_scan_origin_card")
  /// Get a new card
  public static let onboardingButtonShop = LocalizedString(lookupKey: "onboarding_button_shop")
  /// Show the wallet’s address
  public static let onboardingButtonShowAddressQr = LocalizedString(lookupKey: "onboarding_button_show_address_qr")
  /// Skip for later
  public static let onboardingButtonSkipBackup = LocalizedString(lookupKey: "onboarding_button_skip_backup")
  /// Scan the card #1
  public static let onboardingButtonTapFirstCard = LocalizedString(lookupKey: "onboarding_button_tap_first_card")
  /// Scan the card #2
  public static let onboardingButtonTapSecondCard = LocalizedString(lookupKey: "onboarding_button_tap_second_card")
  /// Your card is activated and ready to be used
  public static let onboardingConfettiSubtitle = LocalizedString(lookupKey: "onboarding_confetti_subtitle")
  /// Done!
  public static let onboardingConfettiTitle = LocalizedString(lookupKey: "onboarding_confetti_title")
  /// Let’s generate all the keys on your card and create a secure wallet.
  public static let onboardingCreateSubtitle = LocalizedString(lookupKey: "onboarding_create_subtitle")
  /// Create wallet
  public static let onboardingCreateTitle = LocalizedString(lookupKey: "onboarding_create_title")
  /// Getting started
  public static let onboardingGettingStarted = LocalizedString(lookupKey: "onboarding_getting_started")
  /// Activating card
  public static let onboardingNavbarActivatingCard = LocalizedString(lookupKey: "onboarding_navbar_activating_card")
  /// Creating a backup
  public static let onboardingNavbarTitleCreatingBackup = LocalizedString(lookupKey: "onboarding_navbar_title_creating_backup")
  /// The safest way to buy, use and store cryptocurrency
  public static let onboardingReadSubtitle = LocalizedString(lookupKey: "onboarding_read_subtitle")
  /// Welcome to Tangem
  public static let onboardingReadTitle = LocalizedString(lookupKey: "onboarding_read_title")
  /// You can backup your keys up to two other blank wallet cards.
  public static let onboardingSubtitleBackupCard = LocalizedString(lookupKey: "onboarding_subtitle_backup_card")
  /// This one that you are holding in your hands and the other one with number %@.
  public static func onboardingSubtitleIntro(_ p1: Any) -> String {
    return L10n.tr("Localizable", "onboarding_subtitle_intro", String(describing: p1))
  }
  /// To start the backup process add up to two backup cards.
  public static let onboardingSubtitleNoBackupCards = LocalizedString(lookupKey: "onboarding_subtitle_no_backup_cards")
  /// You can add one more card or finalize the backup process.
  public static let onboardingSubtitleOneBackupCard = LocalizedString(lookupKey: "onboarding_subtitle_one_backup_card")
  /// If the process of creating the wallet gets interrupted in any way, you’ll have to start over.
  public static let onboardingSubtitleResetTwinWarning = LocalizedString(lookupKey: "onboarding_subtitle_reset_twin_warning")
  /// Prepare the backup card with number %@
  public static func onboardingSubtitleScanBackupCard(_ p1: Any) -> String {
    return L10n.tr("Localizable", "onboarding_subtitle_scan_backup_card", String(describing: p1))
  }
  /// Prepare the primary card with number %@
  public static func onboardingSubtitleScanOriginCard(_ p1: Any) -> String {
    return L10n.tr("Localizable", "onboarding_subtitle_scan_origin_card", String(describing: p1))
  }
  /// Scan the primary card to start the backup process.
  public static let onboardingSubtitleScanPrimary = LocalizedString(lookupKey: "onboarding_subtitle_scan_primary")
  /// You have created 2 backup cards, and now these cards are ready for use.
  public static let onboardingSubtitleSuccessBackup = LocalizedString(lookupKey: "onboarding_subtitle_success_backup")
  /// You have created 1 backup card, nd now this card are ready for use.
  public static let onboardingSubtitleSuccessBackupOneCard = LocalizedString(lookupKey: "onboarding_subtitle_success_backup_one_card")
  /// Your Tangem Wallet card is configured and ready for use.
  public static let onboardingSubtitleSuccessTangemWalletOnboarding = LocalizedString(lookupKey: "onboarding_subtitle_success_tangem_wallet_onboarding")
  /// Max number of cards added. Finalize the backup process.
  public static let onboardingSubtitleTwoBackupCards = LocalizedString(lookupKey: "onboarding_subtitle_two_backup_cards")
  /// Success!
  public static let onboardingSuccess = LocalizedString(lookupKey: "onboarding_success")
  /// Your crypto card is activated and ready to be used
  public static let onboardingSuccessSubtitle = LocalizedString(lookupKey: "onboarding_success_subtitle")
  /// Backup your wallet
  public static let onboardingTitleBackupCard = LocalizedString(lookupKey: "onboarding_title_backup_card")
  /// Backup card #%d
  public static func onboardingTitleBackupCardNumber(_ p1: Int) -> String {
    return L10n.tr("Localizable", "onboarding_title_backup_card_number", p1)
  }
  /// No backup cards
  public static let onboardingTitleNoBackupCards = LocalizedString(lookupKey: "onboarding_title_no_backup_cards")
  /// One backup card added
  public static let onboardingTitleOneBackupCard = LocalizedString(lookupKey: "onboarding_title_one_backup_card")
  /// Primary card
  public static let onboardingTitlePrepareOrigin = LocalizedString(lookupKey: "onboarding_title_prepare_origin")
  /// Prepare your card
  public static let onboardingTitleScanOriginCard = LocalizedString(lookupKey: "onboarding_title_scan_origin_card")
  /// Scan the #1 twin card
  public static let onboardingTitleTwinFirstCard = LocalizedString(lookupKey: "onboarding_title_twin_first_card")
  /// Scan the #2 twin card
  public static let onboardingTitleTwinSecondCard = LocalizedString(lookupKey: "onboarding_title_twin_second_card")
  /// Two backup cards added
  public static let onboardingTitleTwoBackupCards = LocalizedString(lookupKey: "onboarding_title_two_backup_cards")
  /// To get started, simply top up the wallet with any amount
  public static let onboardingTopupSubtitle = LocalizedString(lookupKey: "onboarding_topup_subtitle")
  /// To get started, simply top up the wallet with more than 10 XRP
  public static let onboardingTopupSubtitleXrp = LocalizedString(lookupKey: "onboarding_topup_subtitle_xrp")
  /// Activate a wallet
  public static let onboardingTopupTitle = LocalizedString(lookupKey: "onboarding_topup_title")
  /// The twinning process is partly complete. You can’t exit it now.
  public static let onboardingTwinExitWarning = LocalizedString(lookupKey: "onboarding_twin_exit_warning")
  /// You can backup your keys up to two other blank Tangem Wallet cards.
  public static let onboardingWalletInfoSubtitleFirst = LocalizedString(lookupKey: "onboarding_wallet_info_subtitle_first")
  /// Access code can be restored with one of backup cards.
  public static let onboardingWalletInfoSubtitleFourth = LocalizedString(lookupKey: "onboarding_wallet_info_subtitle_fourth")
  /// All the backup cards can be used as full-functoinal with the identical keys.
  public static let onboardingWalletInfoSubtitleSecond = LocalizedString(lookupKey: "onboarding_wallet_info_subtitle_second")
  /// You will be able to set an access code to protect your wallets.
  public static let onboardingWalletInfoSubtitleThird = LocalizedString(lookupKey: "onboarding_wallet_info_subtitle_third")
  /// Backup wallet
  public static let onboardingWalletInfoTitleFirst = LocalizedString(lookupKey: "onboarding_wallet_info_title_first")
  /// Access code restore
  public static let onboardingWalletInfoTitleFourth = LocalizedString(lookupKey: "onboarding_wallet_info_title_fourth")
  /// Identical cards
  public static let onboardingWalletInfoTitleSecond = LocalizedString(lookupKey: "onboarding_wallet_info_title_second")
  /// Access code
  public static let onboardingWalletInfoTitleThird = LocalizedString(lookupKey: "onboarding_wallet_info_title_third")
  /// Invalid PayString
  public static let payidServiceErrorLoading = LocalizedString(lookupKey: "payid_service_error_loading")
  /// Additional fee
  public static let pushAdditionalFee = LocalizedString(lookupKey: "push_additional_fee")
  /// Previous fee
  public static let pushPreviousFee = LocalizedString(lookupKey: "push_previous_fee")
  /// Previous transaction total including fee
  public static let pushTxAddressHint = LocalizedString(lookupKey: "push_tx_address_hint")
  /// Search tokens
  public static let searchTokensTitle = LocalizedString(lookupKey: "search_tokens_title")
  /// Amount
  public static let sendAmountLabel = LocalizedString(lookupKey: "send_amount_label")
  /// Balance: %@
  public static func sendBalanceSubtitleFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "send_balance_subtitle_format", String(describing: p1))
  }
  /// Address or PayString
  public static let sendDestinationHint = LocalizedString(lookupKey: "send_destination_hint")
  /// Address
  public static let sendDestinationHintAddress = LocalizedString(lookupKey: "send_destination_hint_address")
  /// Invalid Destination Tag. It won't be added to transaction
  public static let sendErrorInvalidDestinationTag = LocalizedString(lookupKey: "send_error_invalid_destination_tag")
  /// Invalid Memo Id. It won't be added to transaction
  public static let sendErrorInvalidMemoId = LocalizedString(lookupKey: "send_error_invalid_memo_id")
  /// Destination Tag
  public static let sendExtrasHintDestinationTag = LocalizedString(lookupKey: "send_extras_hint_destination_tag")
  /// Memo
  public static let sendExtrasHintMemo = LocalizedString(lookupKey: "send_extras_hint_memo")
  /// Memo Id
  public static let sendExtrasHintMemoId = LocalizedString(lookupKey: "send_extras_hint_memo_id")
  /// Include fee
  public static let sendFeeIncludeDescription = LocalizedString(lookupKey: "send_fee_include_description")
  /// Fee
  public static let sendFeeLabel = LocalizedString(lookupKey: "send_fee_label")
  /// Low
  public static let sendFeePickerLow = LocalizedString(lookupKey: "send_fee_picker_low")
  /// Normal
  public static let sendFeePickerNormal = LocalizedString(lookupKey: "send_fee_picker_normal")
  /// Priority
  public static let sendFeePickerPriority = LocalizedString(lookupKey: "send_fee_picker_priority")
  /// Maximum amount
  public static let sendMaxAmountLabel = LocalizedString(lookupKey: "send_max_amount_label")
  /// Network fee
  public static let sendNetworkFeeTitle = LocalizedString(lookupKey: "send_network_fee_title")
  /// Sending %@
  public static func sendTitleCurrencyFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "send_title_currency_format", String(describing: p1))
  }
  /// Total
  public static let sendTotalLabel = LocalizedString(lookupKey: "send_total_label")
  /// %@ and %@ will be sent
  public static func sendTotalSubtitleAssetFormat(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "send_total_subtitle_asset_format", String(describing: p1), String(describing: p2))
  }
  /// ≈ %@ (inc. fee: %@)
  public static func sendTotalSubtitleFiatFormat(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "send_total_subtitle_fiat_format", String(describing: p1), String(describing: p2))
  }
  /// %@ will be sent
  public static func sendTotalSubtitleFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "send_total_subtitle_format", String(describing: p1))
  }
  /// Transaction has been successfully signed and sent to the blockchain node. Wallet balance will be updated in a while
  public static let sendTransactionSuccess = LocalizedString(lookupKey: "send_transaction_success")
  /// Invalid address
  public static let sendValidationInvalidAddress = LocalizedString(lookupKey: "send_validation_invalid_address")
  /// 2 cards
  public static let shop2Cards = LocalizedString(lookupKey: "shop_2_cards")
  /// 3 cards
  public static let shop3Cards = LocalizedString(lookupKey: "shop_3_cards")
  /// Buy now
  public static let shopBuyNow = LocalizedString(lookupKey: "shop_buy_now")
  /// Free
  public static let shopFree = LocalizedString(lookupKey: "shop_free")
  /// I have a promo code...
  public static let shopIHaveAPromoCode = LocalizedString(lookupKey: "shop_i_have_a_promo_code")
  /// Tangem Wallet
  public static let shopOneWallet = LocalizedString(lookupKey: "shop_one_wallet")
  /// Other payment methods
  public static let shopOtherPaymentMethods = LocalizedString(lookupKey: "shop_other_payment_methods")
  /// Placing your order
  public static let shopPlacingOrder = LocalizedString(lookupKey: "shop_placing_order")
  /// Shipping
  public static let shopShipping = LocalizedString(lookupKey: "shop_shipping")
  /// Total
  public static let shopTotal = LocalizedString(lookupKey: "shop_total")
  /// Your order
  public static let shopWebCheckoutTitle = LocalizedString(lookupKey: "shop_web_checkout_title")
  /// Solana network charges a rent of %@ every 2 days. Accounts that can’t afford the rent are purged from the network. Deposit your account with more than %@ to use it for free.
  public static func solanaRentWarning(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "solana_rent_warning", String(describing: p1), String(describing: p2))
  }
  /// Store your crypto assets secure while keeping private keys contained in your card
  public static let storyAweDescription = LocalizedString(lookupKey: "story_awe_description")
  /// Revolutionary Hardware Wallet
  public static let storyAweTitle = LocalizedString(lookupKey: "story_awe_title")
  /// Up to
  public static let storyBackupDescription1 = LocalizedString(lookupKey: "story_backup_description_1")
  /// 3 physical cards
  public static let storyBackupDescription2Bold = LocalizedString(lookupKey: "story_backup_description_2_bold")
  /// to one wallet
  public static let storyBackupDescription3 = LocalizedString(lookupKey: "story_backup_description_3")
  /// Ultra Secure Backup
  public static let storyBackupTitle = LocalizedString(lookupKey: "story_backup_title")
  /// A hardware wallet for your Bitcoin, Ethereum and many more currencies simultaneously – all in one card
  public static let storyCurrenciesDescription = LocalizedString(lookupKey: "story_currencies_description")
  /// Thousands of Currencies
  public static let storyCurrenciesTitle = LocalizedString(lookupKey: "story_currencies_title")
  /// Use it on the go, anywhere, anytime. No wires or batteries. Just tap the card to your phone when you need your crypto.
  public static let storyFinishDescription = LocalizedString(lookupKey: "story_finish_description")
  /// The Wallet for Everyone
  public static let storyFinishTitle = LocalizedString(lookupKey: "story_finish_title")
  /// Borrow
  public static let storyMeetBorrow = LocalizedString(lookupKey: "story_meet_borrow")
  /// Buy
  public static let storyMeetBuy = LocalizedString(lookupKey: "story_meet_buy")
  /// Exchange
  public static let storyMeetExchange = LocalizedString(lookupKey: "story_meet_exchange")
  /// Lend
  public static let storyMeetLend = LocalizedString(lookupKey: "story_meet_lend")
  /// Pay
  public static let storyMeetPay = LocalizedString(lookupKey: "story_meet_pay")
  /// Send
  public static let storyMeetSend = LocalizedString(lookupKey: "story_meet_send")
  /// Stake
  public static let storyMeetStake = LocalizedString(lookupKey: "story_meet_stake")
  /// Store
  public static let storyMeetStore = LocalizedString(lookupKey: "story_meet_store")
  /// Meet\nTangem
  public static let storyMeetTitle = LocalizedString(lookupKey: "story_meet_title")
  /// Exchange, buy NFT’s, make loans and deposits in more than 100 different decentralized services
  public static let storyWeb3Description = LocalizedString(lookupKey: "story_web3_description")
  /// DeFi Compatible
  public static let storyWeb3Title = LocalizedString(lookupKey: "story_web3_title")
  /// Transaction signed and sent to testnet. Wait for a while and reload balance
  public static let testnetAddressTopuped = LocalizedString(lookupKey: "testnet_address_topuped")
  /// Failed to create topup transaction for token. Try again later
  public static let testnetErrorFailedCreateTx = LocalizedString(lookupKey: "testnet_error_failed_create_tx")
  /// Not enough funds on ETH wallet balance. You need to topup ETH wallet first
  public static let testnetErrorNotEnoughEtherMessage = LocalizedString(lookupKey: "testnet_error_not_enough_ether_message")
  /// Not enough funds for fee on your %@ wallet to send a transaction. Top up your %@ wallet first.
  public static func tokenDetailsSendBlockedFeeFormat(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "token_details_send_blocked_fee_format", String(describing: p1), String(describing: p2))
  }
  /// Please wait for %@ transaction to complete to be able to send funds
  public static func tokenDetailsSendBlockedTxFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "token_details_send_blocked_tx_format", String(describing: p1))
  }
  /// You've scanned not a twin card. To create twin wallet you need to scan a Tangem Twin card
  public static let twinErrorNotATwinCard = LocalizedString(lookupKey: "twin_error_not_a_twin_card")
  /// You've scanned same card. To create twin wallet you need to scan card with number %d
  public static func twinErrorSameCard(_ p1: Int) -> String {
    return L10n.tr("Localizable", "twin_error_same_card", p1)
  }
  /// You've scanned wrong twin card. Please try another one
  public static let twinErrorWrongTwin = LocalizedString(lookupKey: "twin_error_wrong_twin")
  /// Creating wallet
  public static let twinProcessCreatingWallet = LocalizedString(lookupKey: "twin_process_creating_wallet")
  /// Preparing card
  public static let twinProcessPreparingCard = LocalizedString(lookupKey: "twin_process_preparing_card")
  /// You have already started the process of recreating twin wallet. If you interrupt it, you won't be able to use your twin cards until you start it again and complete recreating the wallet.
  public static let twinsCreationWarningMessage = LocalizedString(lookupKey: "twins_creation_warning_message")
  /// Cancel Twin Card creation?
  public static let twinsCreationWarningTitle = LocalizedString(lookupKey: "twins_creation_warning_title")
  /// This one that you are holding in your hands and the other one with number %@.\n\nBoth cards can be used to extract funds from this wallet.
  public static func twinsOnboardingDescriptionFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "twins_onboarding_description_format", String(describing: p1))
  }
  /// One wallet. Two cards.
  public static let twinsOnboardingSubtitle = LocalizedString(lookupKey: "twins_onboarding_subtitle")
  /// Tangem Twin
  public static let twinsOnboardingTitle = LocalizedString(lookupKey: "twins_onboarding_title")
  /// Hold your iPhone near the twin card with number %@
  public static func twinsScanTwinWithNumber(_ p1: Any) -> String {
    return L10n.tr("Localizable", "twins_scan_twin_with_number", String(describing: p1))
  }
  /// Close network fee settings
  public static let voiceOverCloseNetworkFeeSettings = LocalizedString(lookupKey: "voice_over_close_network_fee_settings")
  /// Copy address
  public static let voiceOverCopyAddress = LocalizedString(lookupKey: "voice_over_copy_address")
  /// Nothing to paste from clipboard
  public static let voiceOverNothingToPaste = LocalizedString(lookupKey: "voice_over_nothing_to_paste")
  /// Open card details
  public static let voiceOverOpenCardDetails = LocalizedString(lookupKey: "voice_over_open_card_details")
  /// Open network fee settings
  public static let voiceOverOpenNetworkFeeSettings = LocalizedString(lookupKey: "voice_over_open_network_fee_settings")
  /// Scan QR code to open new WalletConnect session
  public static let voiceOverOpenNewWalletConnectSession = LocalizedString(lookupKey: "voice_over_open_new_wallet_connect_session")
  /// Paste address from clipboard
  public static let voiceOverPasteFromClipboard = LocalizedString(lookupKey: "voice_over_paste_from_clipboard")
  /// Scan, QR, code with address
  public static let voiceOverScanQrWithAddress = LocalizedString(lookupKey: "voice_over_scan_qr_with_address")
  /// Share address
  public static let voiceOverShareAddress = LocalizedString(lookupKey: "voice_over_share_address")
  /// Show address, QR, code
  public static let voiceOverShowAddressQr = LocalizedString(lookupKey: "voice_over_show_address_qr")
  /// Create PayString
  public static let walletAddressButtonCreatePayid = LocalizedString(lookupKey: "wallet_address_button_create_payid")
  /// Explore address
  public static let walletAddressButtonExplore = LocalizedString(lookupKey: "wallet_address_button_explore")
  /// Blockchain is unreachable
  public static let walletBalanceBlockchainUnreachable = LocalizedString(lookupKey: "wallet_balance_blockchain_unreachable")
  /// Balance is loading…
  public static let walletBalanceLoading = LocalizedString(lookupKey: "wallet_balance_loading")
  /// Transaction is in progress...
  public static let walletBalanceTxInProgress = LocalizedString(lookupKey: "wallet_balance_tx_in_progress")
  /// Verified Balance
  public static let walletBalanceVerified = LocalizedString(lookupKey: "wallet_balance_verified")
  /// Create twin wallet
  public static let walletButtonCreateTwinWallet = LocalizedString(lookupKey: "wallet_button_create_twin_wallet")
  /// Create wallet
  public static let walletButtonCreateWallet = LocalizedString(lookupKey: "wallet_button_create_wallet")
  /// Scan
  public static let walletButtonScan = LocalizedString(lookupKey: "wallet_button_scan")
  /// Sell
  public static let walletButtonSellCrypto = LocalizedString(lookupKey: "wallet_button_sell_crypto")
  /// Send
  public static let walletButtonSend = LocalizedString(lookupKey: "wallet_button_send")
  /// Buy
  public static let walletButtonTopup = LocalizedString(lookupKey: "wallet_button_topup")
  /// Exchange
  public static let walletButtonTrade = LocalizedString(lookupKey: "wallet_button_trade")
  /// Choice wallet option
  public static let walletChoiceWalletOptionTitle = LocalizedString(lookupKey: "wallet_choice_wallet_option_title")
  /// Requesting to sign a message\nwith card %@\n\n%@
  public static func walletConnectAlertSignMessage(_ p1: Any, _ p2: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_alert_sign_message", String(describing: p1), String(describing: p2))
  }
  /// Dapp %@, requesting to\nsign BNB transaction with\nCard: %@\n\n%@
  public static func walletConnectBnbSignMessage(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_bnb_sign_message", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Trade order for %@\nPrice: %@\nAmount to receive: %@\nAmount to pay: %@
  public static func walletConnectBnbTradeOrderMessage(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_bnb_trade_order_message", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4))
  }
  /// Transaction details:\nFrom: %@\nTo: %@\nAmount: %@
  public static func walletConnectBnbTransactionMessage(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_bnb_transaction_message", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// The BNB transaction has been successfully signed and sent to the Dapp
  public static let walletConnectBnbTransactionSigned = LocalizedString(lookupKey: "wallet_connect_bnb_transaction_signed")
  /// Failed to find target card
  public static let walletConnectCardNotFound = LocalizedString(lookupKey: "wallet_connect_card_not_found")
  /// Card: %@
  public static func walletConnectCardNumber(_ p1: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_card_number", String(describing: p1))
  }
  /// Clipboard contain WalletConnect code. Use copied value or scan QR-code
  public static let walletConnectClipboardAlert = LocalizedString(lookupKey: "wallet_connect_clipboard_alert")
  /// Card: %@\nRequest to create transaction for %@\n%@\n\nAmount: %@\nFee: %@\nTotal: %@\nBalance: %@
  public static func walletConnectCreateTxMessage(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any, _ p5: Any, _ p6: Any, _ p7: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_create_tx_message", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4), String(describing: p5), String(describing: p6), String(describing: p7))
  }
  /// \n\nCan't send transaction. Not enough funds.
  public static let walletConnectCreateTxNotEnoughFunds = LocalizedString(lookupKey: "wallet_connect_create_tx_not_enough_funds")
  /// Failed to establish WalletConnect session.\nPlease, try again later.
  public static let walletConnectErrorFailedToConnect = LocalizedString(lookupKey: "wallet_connect_error_failed_to_connect")
  /// Failed to sign message.\nPlease, try again
  public static let walletConnectErrorSingFailed = LocalizedString(lookupKey: "wallet_connect_error_sing_failed")
  /// Failed to establish WalletConnect session: timeout error.\nPlease, try again later.
  public static let walletConnectErrorTimeout = LocalizedString(lookupKey: "wallet_connect_error_timeout")
  /// Failed to create transaction from Dapp data. Code: %@
  public static func walletConnectFailedToBuildTx(_ p1: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_failed_to_build_tx", String(describing: p1))
  }
  /// The message has been successfully signed and sent to the Dapp
  public static let walletConnectMessageSigned = LocalizedString(lookupKey: "wallet_connect_message_signed")
  /// %@ network not found. Please, add it first and try again.
  public static func walletConnectNetworkNotFoundFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_network_not_found_format", String(describing: p1))
  }
  /// No opened WalletConnect sessions
  public static let walletConnectNoSessionsMessage = LocalizedString(lookupKey: "wallet_connect_no_sessions_message")
  /// Ooops. No Sessions.
  public static let walletConnectNoSessionsTitle = LocalizedString(lookupKey: "wallet_connect_no_sessions_title")
  /// Paste from clipboard
  public static let walletConnectPasteFromClipboard = LocalizedString(lookupKey: "wallet_connect_paste_from_clipboard")
  /// Message for %@:\n
  public static func walletConnectPersonalSignMessage(_ p1: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_personal_sign_message", String(describing: p1))
  }
  /// Request to start a session for card with ID %@\nfor\n%@\n\nURL: %@
  public static func walletConnectRequestSessionStart(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
    return L10n.tr("Localizable", "wallet_connect_request_session_start", String(describing: p1), String(describing: p2), String(describing: p3))
  }
  /// Tap card to bind to wallet connect
  public static let walletConnectScanCardMessage = LocalizedString(lookupKey: "wallet_connect_scan_card_message")
  /// Scan new code
  public static let walletConnectScanNewCode = LocalizedString(lookupKey: "wallet_connect_scan_new_code")
  /// This card can’t be used to establish WalletConnect session
  public static let walletConnectScannerErrorNotValidCard = LocalizedString(lookupKey: "wallet_connect_scanner_error_not_valid_card")
  /// This network is not supported
  public static let walletConnectScannerErrorUnsupportedNetwork = LocalizedString(lookupKey: "wallet_connect_scanner_error_unsupported_network")
  /// Dapp didn't provide essential data to establish WalletConnect session
  public static let walletConnectServiceNoChainId = LocalizedString(lookupKey: "wallet_connect_service_no_chain_id")
  /// Failed to find session for request
  public static let walletConnectSessionNotFound = LocalizedString(lookupKey: "wallet_connect_session_not_found")
  /// WalletConnect Sessions
  public static let walletConnectSessionsTitle = LocalizedString(lookupKey: "wallet_connect_sessions_title")
  /// The transaction has been successfully signed and sent to the Dapp
  public static let walletConnectTransactionSigned = LocalizedString(lookupKey: "wallet_connect_transaction_signed")
  /// The transaction has been succesfully signed and sent to the blockchain
  public static let walletConnectTransactionSignedAndSend = LocalizedString(lookupKey: "wallet_connect_transaction_signed_and_send")
  /// Failed to find transaction hash
  public static let walletConnectTxNotFound = LocalizedString(lookupKey: "wallet_connect_tx_not_found")
  /// Create PayString
  public static let walletCreatePayid = LocalizedString(lookupKey: "wallet_create_payid")
  /// Create
  public static let walletCreatePayidButtonTitle = LocalizedString(lookupKey: "wallet_create_payid_button_title")
  /// Card: %@
  public static func walletCreatePayidCardFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "wallet_create_payid_card_format", String(describing: p1))
  }
  /// $payid.tangem.com
  public static let walletCreatePayidDomain = LocalizedString(lookupKey: "wallet_create_payid_domain")
  /// This PayString already exists. Try a different one.
  public static let walletCreatePayidErrorAlreadyCreated = LocalizedString(lookupKey: "wallet_create_payid_error_already_created")
  /// Error response while creating PayString
  public static let walletCreatePayidErrorMessage = LocalizedString(lookupKey: "wallet_create_payid_error_message")
  /// PayString name
  public static let walletCreatePayidHint = LocalizedString(lookupKey: "wallet_create_payid_hint")
  /// Your PayString is information unique to you, like your phone number, email or ABN.
  public static let walletCreatePayidInfo = LocalizedString(lookupKey: "wallet_create_payid_info")
  /// PayString created successfully and copied to clipboard
  public static let walletCreatePayidSuccessMessage = LocalizedString(lookupKey: "wallet_create_payid_success_message")
  /// Empty card
  public static let walletErrorEmptyCard = LocalizedString(lookupKey: "wallet_error_empty_card")
  /// Create wallet to start using Tangem card
  public static let walletErrorEmptyCardSubtitle = LocalizedString(lookupKey: "wallet_error_empty_card_subtitle")
  /// Create twin wallet
  public static let walletErrorEmptyTwinCard = LocalizedString(lookupKey: "wallet_error_empty_twin_card")
  /// Generate wallet keys on both cards to start using your Twins
  public static let walletErrorEmptyTwinCardSubtitle = LocalizedString(lookupKey: "wallet_error_empty_twin_card_subtitle")
  /// Account is not created
  public static let walletErrorNoAccount = LocalizedString(lookupKey: "wallet_error_no_account")
  /// This card is not supported
  public static let walletErrorUnsupportedBlockchain = LocalizedString(lookupKey: "wallet_error_unsupported_blockchain")
  /// Your Tangem card was made to work with a different application. Please see the name and instructions on your card, and install the correct app
  public static let walletErrorUnsupportedBlockchainSubtitle = LocalizedString(lookupKey: "wallet_error_unsupported_blockchain_subtitle")
  /// Receiving
  public static let walletPendingTxReceiving = LocalizedString(lookupKey: "wallet_pending_tx_receiving")
  /// from %@
  public static func walletPendingTxReceivingAddressFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "wallet_pending_tx_receiving_address_format", String(describing: p1))
  }
  /// Sending
  public static let walletPendingTxSending = LocalizedString(lookupKey: "wallet_pending_tx_sending")
  /// to %@
  public static func walletPendingTxSendingAddressFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "wallet_pending_tx_sending_address_format", String(describing: p1))
  }
  /// Remove token
  public static let walletRemoveToken = LocalizedString(lookupKey: "wallet_remove_token")
  /// Tangem
  public static let walletTitle = LocalizedString(lookupKey: "wallet_title")
  /// Can be better
  public static let warningButtonCanBeBetter = LocalizedString(lookupKey: "warning_button_can_be_better")
  /// Learn more
  public static let warningButtonLearnMore = LocalizedString(lookupKey: "warning_button_learn_more")
  /// Ok, Got it!
  public static let warningButtonOk = LocalizedString(lookupKey: "warning_button_ok")
  /// Really cool!
  public static let warningButtonReallyCool = LocalizedString(lookupKey: "warning_button_really_cool")
  /// This card might be a production sample or counterfeit
  public static let warningFailedToVerifyCardMessage = LocalizedString(lookupKey: "warning_failed_to_verify_card_message")
  /// Authenticity check failed
  public static let warningFailedToVerifyCardTitle = LocalizedString(lookupKey: "warning_failed_to_verify_card_title")
  /// Important security information ⚠
  public static let warningImportantSecurityInfo = LocalizedString(lookupKey: "warning_important_security_info")
  /// There are only %@ signatures available on this card. You must withdraw all of your funds.
  public static func warningLowSignaturesFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "warning_low_signatures_format", String(describing: p1))
  }
  /// How do you like Tangem?
  public static let warningRateAppMessage = LocalizedString(lookupKey: "warning_rate_app_message")
  /// One question
  public static let warningRateAppTitle = LocalizedString(lookupKey: "warning_rate_app_title")
  /// This card has signed transactions in the past
  public static let warningSignedTxPreviously = LocalizedString(lookupKey: "warning_signed_tx_previously")
  /// This is a Testnet card. Don't accept it as a payment. This card must only be used for testing and development purposes
  public static let warningTestnetCardMessage = LocalizedString(lookupKey: "warning_testnet_card_message")
  /// Do not transfer your funds to tokens in this blockchain, otherwise it may lead to their irretrievable loss.
  public static let warningTokenSendUnsupportedMessage = LocalizedString(lookupKey: "warning_token_send_unsupported_message")
  /// Discard
  public static let welcomeInterruptedBackupAlertDiscard = LocalizedString(lookupKey: "welcome_interrupted_backup_alert_discard")
  /// You have an interrupted backup. Do you want to resume?
  public static let welcomeInterruptedBackupAlertMessage = LocalizedString(lookupKey: "welcome_interrupted_backup_alert_message")
  /// Yes, resume
  public static let welcomeInterruptedBackupAlertResume = LocalizedString(lookupKey: "welcome_interrupted_backup_alert_resume")
  /// Discard
  public static let welcomeInterruptedBackupDiscardDiscard = LocalizedString(lookupKey: "welcome_interrupted_backup_discard_discard")
  /// If you will discard the backup now, then you will have to reset the cards to factory settings to start over again
  public static let welcomeInterruptedBackupDiscardMessage = LocalizedString(lookupKey: "welcome_interrupted_backup_discard_message")
  /// Resume backup
  public static let welcomeInterruptedBackupDiscardResume = LocalizedString(lookupKey: "welcome_interrupted_backup_discard_resume")
  /// This is an irreversible action
  public static let welcomeInterruptedBackupDiscardTitle = LocalizedString(lookupKey: "welcome_interrupted_backup_discard_title")
}

// MARK: - Implementation Details

extension L10n {
  fileprivate static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

public struct LocalizedString {
  internal let lookupKey: String

  var key: LocalizedStringKey {
    LocalizedStringKey(lookupKey)
  }

  var text: String {
    L10n.tr("Localizable", lookupKey)
  }
}

private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
      return Bundle.module
    #else
      return Bundle(for: BundleToken.self)
    #endif
  }()
}
