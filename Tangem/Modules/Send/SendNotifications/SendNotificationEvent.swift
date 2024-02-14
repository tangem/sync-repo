//
//  SendNotificationEvent.swift
//  Tangem
//
//  Created by Andrey Chukavin on 29.01.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

enum SendNotificationEvent {
    case networkFeeUnreachable
}

extension SendNotificationEvent: NotificationEvent {
    var title: NotificationView.Title {
        switch self {
        case .networkFeeUnreachable:
            return .string(Localization.sendFeeUnreachableErrorTitle)
        }
    }

    var description: String? {
        switch self {
        case .networkFeeUnreachable:
            return Localization.sendFeeUnreachableErrorText
        }
    }

    var colorScheme: NotificationView.ColorScheme {
        switch self {
        case .networkFeeUnreachable:
            return .primary
        }
    }

    var icon: NotificationView.MessageIcon {
        switch self {
        case .networkFeeUnreachable:
            return .init(iconType: .image(Assets.attention.image))
        }
    }

    var severity: NotificationView.Severity {
        switch self {
        case .networkFeeUnreachable:
            return .critical
        }
    }

    var isDismissable: Bool {
        switch self {
        case .networkFeeUnreachable:
            return false
        }
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
    var buttonActionType: NotificationButtonActionType? {
        switch self {
        case .networkFeeUnreachable:
            return .refreshFee
        }
    }
}
