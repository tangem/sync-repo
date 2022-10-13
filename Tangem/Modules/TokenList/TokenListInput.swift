//
//  TokenListInput.swift
//  Tangem
//
//  Created by Sergey Balashov on 13.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import enum BlockchainSdk.Blockchain
import struct TangemSdk.DerivationPath

protocol TokenListMaintainer {
    var walletModels: [WalletModel] { get }
    
    func getEntriesFromRepository() -> [StorageEntry]
    func getBlockchainNetwork(for blockchain: Blockchain, derivationPath: DerivationPath?) -> BlockchainNetwork
    func update(entries: [StorageEntry], completion: @escaping (Result<Void, Error>) -> Void)
}

struct TokenListInput {
    let config: UserWalletConfig
    let tokenListMaintainer: TokenListMaintainer
}
