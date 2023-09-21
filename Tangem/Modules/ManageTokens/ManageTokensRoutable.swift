//
//  ManageTokensRoutable.swift
//  Tangem
//
//  Created by skibinalexander on 14.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol ManageTokensRoutable: AnyObject {
    func openInfoTokenModule(with coin: CoinModel)
    func openEditTokenModule(with coin: CoinModel)
    func openAddTokenModule(with coin: CoinModel)
    func openAddCustomTokenModule(settings: LegacyManageTokensSettings, userTokensManager: UserTokensManager)
}
