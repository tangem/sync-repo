//
//  UnspentOutput.swift
//  TangemApp
//
//  Created by Sergey Balashov on 24.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

// Unspent transaction output
// Uncomf
// Response ✅ 200: btcbook.nownodes.io; Info: /api/v2/utxo/bc1qrc458kmvxa46h6h5ypfsvec7pzzevj9lht48v5;
// Body: [{"txid":"c6d6d4d3775a8b5421ca5fb893e5637865431c2147e5d00edb0546847858cb19","vout":1,"value":"1850200","confirmations":0,"lockTime":884710}]

struct UnspentOutput {
    /// a.k.a `height`. The block which included the output. For unconfirmed `-1`
    let blockId: UInt64
    /// The hash of transaction where the output was received
    /// DO NOT `reverse()` it  It should do a transaction builder
    let hash: String
    /// The index of the output in transaction
    let index: Int
    /// The amount / value in the smallest denomination e.g. satoshi
    let amount: UInt64

    var isConfirmed: Bool { blockId > 0 }
}

struct ScriptUnspentOutput {
    let output: UnspentOutput
    let script: Data
}
