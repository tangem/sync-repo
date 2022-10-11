//
//  TokenDetailsInput.swift
//  Tangem
//
//  Created by Sergey Balashov on 11.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import struct BlockchainSdk.Amount

protocol TokenDetailsMaintainer {
    func canManage(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool
    func remove(item: CommonUserWalletModel.RemoveItem, completion: @escaping () -> Void)
}

struct TokenDetailsInput {
    let walletModel: WalletModel
    let amountType: Amount.AmountType
    let config: UserWalletConfig
    let userWalletModel: UserWalletModel
}
