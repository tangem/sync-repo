//
//  WarningEvent.swift
//  Tangem
//
//  Created by Andrew Son on 22/12/20.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

enum WarningEvent: Equatable {
    case numberOfSignedHashesIncorrect
    case multiWalletSignedHashes
    case rateApp
    case failedToValidateCard
    case testnetCard
    case demoCard
    case oldDeviceOldCard
    case oldCard
    case devCard
    case lowSignatures(count: Int)
    case legacyDerivation
    case systemDeprecationTemporary
    case systemDeprecationPermanent(String)
}

// For Notifications
extension WarningEvent {
    var defaultTitle: String {
        Localization.commonWarning
    }

    var title: String {
        switch self {
        case .multiWalletSignedHashes:
            return Localization.warningImportantSecurityInfo("")
        case .rateApp:
            return Localization.warningRateAppTitle
        case .failedToValidateCard:
            return Localization.warningFailedToVerifyCardTitle
        case .legacyDerivation:
            return Localization.alertManageTokensAddressesMessage
        case .systemDeprecationTemporary:
            return Localization.warningSystemUpdateTitle
        case .systemDeprecationPermanent:
            return Localization.warningSystemDeprecationTitle
        case .testnetCard, .demoCard, .oldDeviceOldCard, .oldCard, .devCard, .lowSignatures, .numberOfSignedHashesIncorrect:
            return defaultTitle
        }
    }

    var description: String {
        switch self {
        case .numberOfSignedHashesIncorrect:
            return Localization.alertCardSignedTransactions
        case .multiWalletSignedHashes:
            return Localization.warningSignedTxPreviously
        case .rateApp:
            return Localization.warningRateAppMessage
        case .failedToValidateCard:
            return Localization.warningFailedToVerifyCardMessage
        case .testnetCard:
            return Localization.warningTestnetCardMessage
        case .demoCard:
            return Localization.alertDemoMessage
        case .oldDeviceOldCard:
            return Localization.alertOldDeviceThisCard
        case .oldCard:
            return Localization.alertOldCard
        case .devCard:
            return Localization.alertDeveloperCard
        case .lowSignatures(let count):
            return Localization.warningLowSignaturesFormat("\(count)")
        case .legacyDerivation:
            return Localization.alertManageTokensAddressesMessage
        case .systemDeprecationTemporary:
            return Localization.warningSystemUpdateMessage
        case .systemDeprecationPermanent(let dateString):
            return String(format: Localization.warningSystemDeprecationWithDateMessage(dateString))
                .replacingOccurrences(of: "..", with: ".")
        }
    }

    var colorScheme: NotificationView.ColorScheme {
        switch self {
        case .rateApp:
            return .white
        default:
            return .gray
        }
    }

    var icon: NotificationView.MessageIcon {
        switch self {
        case .multiWalletSignedHashes, .numberOfSignedHashesIncorrect, .failedToValidateCard, .testnetCard, .devCard, .oldDeviceOldCard, .oldCard, .demoCard:
            return .init(image: Assets.attention.image)
        case .rateApp, .lowSignatures, .legacyDerivation, .systemDeprecationTemporary, .systemDeprecationPermanent:
            return .init(image: Assets.attentionRed.image)
        }
    }

    var isDismissable: Bool {
        switch self {
        case .multiWalletSignedHashes, .numberOfSignedHashesIncorrect, .failedToValidateCard, .testnetCard, .devCard, .oldDeviceOldCard, .oldCard, .demoCard, .lowSignatures, .legacyDerivation, .systemDeprecationTemporary, .systemDeprecationPermanent:
            return false
        case .rateApp:
            return true
        }
    }

    var withAction: Bool {
        switch self {
        case .multiWalletSignedHashes:
            return true
        default:
            return false
        }
    }
}
