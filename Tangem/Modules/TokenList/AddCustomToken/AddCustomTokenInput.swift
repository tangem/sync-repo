//
//  AddCustomTokenInput.swift
//  Tangem
//
//  Created by Sergey Balashov on 13.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import enum BlockchainSdk.Blockchain
import struct BlockchainSdk.Amount
import struct TangemSdk.DerivationPath

protocol AddCustomTokenMaintainer: TokenListMaintainer {
    func getEntriesFromRepository() -> [StorageEntry]
    func getBlockchainNetwork(for blockchain: Blockchain, derivationPath: DerivationPath?) -> BlockchainNetwork
    func add(entries: [StorageEntry], completion: @escaping (Result<Void, Error>) -> Void)
    func canManage(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool
}

struct AddCustomTokenInput {
    let config: UserWalletConfig
    let addCustomTokenMaintainer: AddCustomTokenMaintainer
}
