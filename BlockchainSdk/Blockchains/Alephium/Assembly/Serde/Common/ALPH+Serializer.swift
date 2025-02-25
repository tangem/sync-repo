//
//  Alephium+Serializer.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 11.01.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension ALPH {
    protocol Serializer {
        associatedtype T

        func serialize(_ input: T) -> Data
    }
}
