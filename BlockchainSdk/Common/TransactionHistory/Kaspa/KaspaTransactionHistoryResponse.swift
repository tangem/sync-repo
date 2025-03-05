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
        let transactionId: String
        let hash: String
        let blockTime: Date
        let isAccepted: Bool
        let inputs: [Input]
        let outputs: [Output]

        struct Input: Decodable {
            let previousOutpointAddress: String
            let previousOutpointAmount: Int
        }

        struct Output: Decodable {
            let amount: Int
            let scriptPublicKeyAddress: String
        }
    }
}
