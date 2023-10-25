//
//  ManageTokensSettingsFactory.swift
//  Tangem
//
//  Created by skibinalexander on 25.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct ManageTokensSettingsFactory {
    func make(from cardViewModel: CardViewModel?) -> ManageTokensSettings {
        .init(
            supportedBlockchains: cardViewModel?.config.supportedBlockchains ?? [],
            hdWalletsSupported: cardViewModel?.userWallet.isHDWalletAllowed ?? false,
            longHashesSupported: cardViewModel?.longHashesSupported ?? false,
            derivationStyle: cardViewModel?.config.derivationStyle,
            shouldShowLegacyDerivationAlert: cardViewModel?.shouldShowLegacyDerivationAlert ?? false,
            existingCurves: cardViewModel?.card.walletCurves ?? []
        )
    }
}
