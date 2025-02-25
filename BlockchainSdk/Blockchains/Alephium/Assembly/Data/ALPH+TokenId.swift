//
//  ALPH+TokenId.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 03.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension ALPH {
    /// Represents a token ID, which is a wrapper around a `Hash`.
    struct TokenId: Hashable {
        let value: Data
    }
}
