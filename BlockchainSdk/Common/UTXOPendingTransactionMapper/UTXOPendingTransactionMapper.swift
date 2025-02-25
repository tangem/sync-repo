//
//  UTXOPendingTransactionMapper.swift
//  TangemApp
//
//  Created by Sergey Balashov on 25.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct UTXOPendingTransactionMapper {
    private let blockchain: Blockchain

    init(blockchain: Blockchain) {
        assert(blockchain.isUTXO, "UTXOPendingTransactionMapper support only UTXO blockchains")

        self.blockchain = blockchain
    }

    func mapPendingTransactionRecord(transaction: Transaction, address: String) throws -> PendingTransactionRecord {
        let isIncoming = !transaction.vin.contains(where: { $0.addresses.contains(address) })
        let outs = transaction.vout
        let destination = outs.first?.addresses.first(where: { $0 != address }) ?? .unknown

        let value: UInt64 = {
            if isIncoming {
                // All outs which was sent only to `wallet` address
                return outs.filter { $0.addresses.contains(address) }.reduce(0) { $0 + $1.amount }
            }

            // All outs which was sent only to `other` addresses
            return outs.filter { !$0.addresses.contains(address) }.reduce(0) { $0 + $1.amount }
        }()

        return PendingTransactionRecord(
            hash: transaction.hash,
            source: isIncoming ? destination : address,
            destination: isIncoming ? address : destination,
            amount: .init(with: blockchain, type: .coin, value: Decimal(value) / blockchain.decimalValue),
            fee: Fee(.init(with: blockchain, type: .coin, value: Decimal(transaction.fee) / blockchain.decimalValue)),
            date: transaction.date,
            isIncoming: isIncoming,
            // For UTXO only one transactionType is applicable
            transactionType: .transfer
        )
    }
}

// MARK: - Protocols

extension UTXOPendingTransactionMapper {
    struct Transaction {
        let hash: String
        let fee: UInt64
        let date: Date
        let vin: [Input]
        let vout: [Output]
    }

    struct Input {
        var addresses: [String]
        var amount: UInt64
    }

    typealias Output = Input
}
