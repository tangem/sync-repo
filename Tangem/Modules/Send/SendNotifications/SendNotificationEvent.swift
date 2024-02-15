//
//  SendNotificationEvent.swift
//  Tangem
//
//  Created by Andrey Chukavin on 29.01.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

enum SendNotificationEvent {
    case networkFeeUnreachable
    // When fee currency is same as fee currency
    case totalExceedsBalance(configuration: TransactionSendAvailabilityProvider.SendingRestrictions.NotEnoughFeeConfiguration)
    // When fee currency is different
    case feeExceedsBalance(configuration: TransactionSendAvailabilityProvider.SendingRestrictions.NotEnoughFeeConfiguration)
    case customFeeTooHigh(orderOfMagnitude: Int)
    case customFeeTooLow
    case feeCoverage
    case minimumAmount(value: String)
    case invalidReserve(value: String)
}

extension SendNotificationEvent: NotificationEvent {
    var title: NotificationView.Title {
        switch self {
        case .networkFeeUnreachable:
            return .string(Localization.sendFeeUnreachableErrorTitle)
        case .totalExceedsBalance:
            return .string(Localization.sendNotificationExceedBalanceTitle)
        case .feeExceedsBalance(let configuration):
            return .string(Localization.warningSendBlockedFundsForFeeTitle(configuration.networkName))
        case .customFeeTooHigh:
            return .string(Localization.sendNotificationFeeTooHighTitle)
        case .customFeeTooLow:
            return .string(Localization.sendNotificationTransactionDelayTitle)
        case .feeCoverage:
            return .string(Localization.sendNetworkFeeWarningTitle)
        case .minimumAmount:
            return .string(Localization.sendNotificationInvalidAmountTitle)
        case .invalidReserve(let value):
            return .string(Localization.sendNotificationInvalidReserveAmountTitle(value))
        }
    }

    var description: String? {
        switch self {
        case .networkFeeUnreachable:
            return Localization.sendFeeUnreachableErrorText
        case .totalExceedsBalance:
            return Localization.sendNotificationExceedBalanceText
        case .feeExceedsBalance(let configuration):
            return Localization.warningSendBlockedFundsForFeeMessage(
                configuration.transactionAmountTypeName,
                configuration.networkName,
                configuration.transactionAmountTypeName,
                configuration.feeAmountTypeName,
                configuration.feeAmountTypeCurrencySymbol
            )
        case .customFeeTooHigh(let orderOfMagnitude):
            return Localization.sendNotificationFeeTooHighText(orderOfMagnitude)
        case .customFeeTooLow:
            return Localization.sendNotificationTransactionDelayText
        case .feeCoverage:
            return Localization.sendNetworkFeeWarningContent
        case .minimumAmount(let value):
            return Localization.sendNotificationInvalidMinimumAmountText(value)
        case .invalidReserve:
            return Localization.sendNotificationInvalidReserveAmountText
        }
    }

    var colorScheme: NotificationView.ColorScheme {
        switch self {
        case .networkFeeUnreachable, .totalExceedsBalance, .feeExceedsBalance:
            return .primary
        case .customFeeTooHigh, .customFeeTooLow, .feeCoverage, .minimumAmount, .invalidReserve:
            return .secondary
        }
    }

    var icon: NotificationView.MessageIcon {
        switch self {
        case .minimumAmount, .invalidReserve:
            // ⚠️ sync with SendNotificationEvent.icon
            return .init(iconType: .image(Assets.redCircleWarning.image))
        case .networkFeeUnreachable, .customFeeTooHigh, .customFeeTooLow, .feeCoverage:
            // ⚠️ sync with SendNotificationEvent.icon
            return .init(iconType: .image(Assets.attention.image))
        case .totalExceedsBalance(let configuration), .feeExceedsBalance(let configuration):
            // ⚠️ sync with SendNotificationEvent.icon
            return .init(iconType: .image(Image(configuration.feeAmountTypeIconName)))
        }
    }

    var severity: NotificationView.Severity {
        switch self {
        case .minimumAmount, .invalidReserve:
            // ⚠️ sync with SendNotificationEvent.icon
            return .critical
        case .networkFeeUnreachable, .customFeeTooHigh, .customFeeTooLow, .feeCoverage:
            // ⚠️ sync with SendNotificationEvent.icon
            return .warning
        case .totalExceedsBalance(let configuration), .feeExceedsBalance(let configuration):
            // ⚠️ sync with SendNotificationEvent.icon
            return .critical
        }
    }

    var isDismissable: Bool {
        false
    }

    var analyticsEvent: Analytics.Event? {
        nil
    }

    var analyticsParams: [Analytics.ParameterKey: String] {
        [:]
    }

    var isOneShotAnalyticsEvent: Bool {
        false
    }
}

extension SendNotificationEvent {
    enum Location {
        case feeLevels
        case customFee
        case feeIncluded
        case summary
    }

    var location: Location {
        switch self {
        case .networkFeeUnreachable, .totalExceedsBalance, .feeExceedsBalance:
            return .feeLevels
        case .customFeeTooHigh, .customFeeTooLow:
            return .customFee
        case .feeCoverage:
            return .feeIncluded
        case .minimumAmount, .invalidReserve:
            return .summary
        }
    }
}

extension SendNotificationEvent {
    var buttonActionType: NotificationButtonActionType? {
        switch self {
        case .networkFeeUnreachable:
            return .refreshFee
        case .totalExceedsBalance(let configuration), .feeExceedsBalance(let configuration):
            return .openFeeCurrency(currencySymbol: configuration.feeAmountTypeCurrencySymbol)
        case .customFeeTooHigh, .customFeeTooLow, .feeCoverage, .minimumAmount, .invalidReserve:
            return nil
        }
    }
}
