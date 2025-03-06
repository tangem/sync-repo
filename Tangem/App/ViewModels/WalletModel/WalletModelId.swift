//
//  WalletModelId.swift
//  Tangem
//
//  Created by Andrew Son on 06/03/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct WalletModelId: Hashable, Identifiable, Equatable {
    let id: String
    let tokenItem: TokenItem

    init(tokenItem: TokenItem) {
        self.tokenItem = tokenItem

        let network = tokenItem.networkId
        let contract = tokenItem.contractAddress ?? "coin"
        let path = tokenItem.blockchainNetwork.derivationPath?.rawPath ?? "no_derivation"
        id = "\(network)_\(contract)_\(path)"
    }
}
