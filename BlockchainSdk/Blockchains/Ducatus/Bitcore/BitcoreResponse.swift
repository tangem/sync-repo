//
//  BitcoreResponse.swift
//  TangemKit
//
//  Created by Alexander Osokin on 03.02.2020.
//  Copyright © 2020 Smart Cash AG. All rights reserved.
//

import Foundation

struct BitcoreBalance: Codable {
    var confirmed: Int64?
    var unconfirmed: Int64?
}

struct BitcoreUtxo: Codable {
    let mintHeight: Int?
    let mintTxid: String?
    let mintIndex: Int?
    let value: UInt64?
    let script: String?
}

struct BitcoreSendResponse: Codable {
    var txid: String?
}
