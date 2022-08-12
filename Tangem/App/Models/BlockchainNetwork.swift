//
//  BlockchainNetwork.swift
//  Tangem
//
//  Created by Alexander Osokin on 31.03.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk
import struct TangemSdk.DerivationPath

struct BlockchainNetwork: Codable, Hashable, Equatable {
    let blockchain: Blockchain
    let derivationPath: DerivationPath?

    // Remove optional
    init(_ blockchain: Blockchain, derivationPath: DerivationPath? = nil) {
        self.blockchain = blockchain
        self.derivationPath = derivationPath
    }
}
