//
//  ALPH+OutputType.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 03.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension ALPH {
    /// A protocol representing an output type in the Alephium blockchain
    protocol OutputType {
        /// The cached level of the output
        var cachedLevel: Int { get }
    }
}
