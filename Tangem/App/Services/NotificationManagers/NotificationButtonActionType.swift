//
//  NotificationButtonActionType.swift
//  Tangem
//
//  Created by Andrew Son on 04/09/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum NotificationButtonActionType: Identifiable, Hashable {
    case generateAddresses
    case backupCard
    case buyCrypto(currencySymbol: String?)
    case openNetworkCurrency(currencySymbol: String)
    case refresh
    case goToProvider
    case exchange

    var id: Int { hashValue }

    var title: String {
        switch self {
        case .generateAddresses:
            return Localization.commonGenerateAddresses
        case .backupCard:
            return Localization.buttonStartBackupProcess
        case .buyCrypto(let currencySymbol):
            guard let currencySymbol else {
                // TODO: Replace when texts will be confirmed
                return "Top up card"
            }
            return Localization.commonBuyCurrency(currencySymbol)
        case .openNetworkCurrency(let currencySymbol):
            return Localization.commonBuyCurrency(currencySymbol)
        case .refresh:
            return Localization.warningButtonRefresh
        case .goToProvider:
            return Localization.expressGoToProvider
        case .exchange:
            return Localization.tokenSwapPromotionButton
        }
    }

    var icon: MainButton.Icon? {
        switch self {
        case .generateAddresses:
            return .trailing(Assets.tangemIcon)
        case .exchange:
            return .leading(Assets.exchangeMini)
        case .backupCard, .buyCrypto, .openNetworkCurrency, .refresh, .goToProvider:
            return nil
        }
    }

    var style: MainButton.Style {
        switch self {
        case .generateAddresses:
            return .primary
        case .backupCard, .buyCrypto, .openNetworkCurrency, .refresh, .goToProvider:
            return .secondary
        case .exchange:
            return .exchangePromotionWhite
        }
    }
}
