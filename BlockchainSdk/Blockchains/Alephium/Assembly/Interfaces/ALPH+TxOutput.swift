//
//  ALPH+TxOutput.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 07.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension ALPH {
    protocol TxOutput {
        var amount: U256 { get }
        var lockupScript: LockupScript { get }
        var tokens: [(TokenId, U256)] { get }
        var hint: Hint { get }

        var isAsset: Bool { get }
        var isContract: Bool { get }

        func payGasUnsafe(fee: U256) -> TxOutput
    }
}
