//
//  MultiWalletMainContentRoutable.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol MultiWalletMainContentRoutable: SingleTokenBaseRoutable {
    func openTokenDetails(for model: WalletModel, mainCurrencyWalletModel: WalletModel?, userWalletModel: UserWalletModel)
    func openOrganizeTokens(for userWalletModel: UserWalletModel)
    func openOnboardingModal(with input: OnboardingInput)
    func openManageTokens(with settings: LegacyManageTokensSettings, userTokensManager: UserTokensManager)
}
