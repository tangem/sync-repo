//
//  DetailsInput.swift
//  Tangem
//
//  Created by Sergey Balashov on 12.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol DetailsInputMaintainer {
    var backupInput: OnboardingInput? { get }
    var walletModels: [WalletModel] { get }
}

struct DetailsInput {
    let config: UserWalletConfig
    let cardId: String
    let detailsInputMaintainer: DetailsInputMaintainer
}
