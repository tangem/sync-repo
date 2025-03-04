//
//  KaspaTransactionHistoryResponse.swift
//  TangemApp
//
//  Created by Dmitry Fedorov on 04.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct KaspaTransactionHistoryResponse: Decodable {
    let transactions: [Transaction]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        transactions = try container.decode([Transaction].self)
    }

    struct Transaction: Decodable {
        let subnetworkId: String
        let transactionId: String
        let hash: String
        let mass: String
        let payload: String?
        let blockHash: [String]
        let blockTime: Date
        let isAccepted: Bool
        let acceptingBlockHash: String
        let acceptingBlockBlueScore: Int
        let inputs: [Input]
        let outputs: [Output]

        struct Input: Decodable {
            let transactionId: String
            let index: Int
            let previousOutpointHash: String
            let previousOutpointIndex: String
            let previousOutpointResolved: String?
            let previousOutpointAddress: String
            let previousOutpointAmount: Int
            let signatureScript: String
            let sigOpCount: String
        }

        struct Output: Decodable {
            let transactionId: String
            let index: Int
            let amount: Int
            let scriptPublicKey: String
            let scriptPublicKeyAddress: String
            let scriptPublicKeyType: String
            let acceptingBlockHash: String?
        }
    }
}
