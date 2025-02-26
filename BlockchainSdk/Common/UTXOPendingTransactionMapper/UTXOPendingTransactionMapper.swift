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

    func mapToPendingTransactionRecord(transaction: Transaction, address: String) throws -> PendingTransactionRecord {
        let isIncoming = !transaction.vin.contains(where: { $0.address == address })
        let outs = transaction.vout
        let destination = outs.first(where: { $0.address != address })?.address ?? .unknown

        let value: UInt64 = {
            if isIncoming {
                // All outs which was sent only to `wallet` address
                return outs.filter { $0.address == address }.reduce(0) { $0 + $1.amount }
            }

            // All outs which was sent only to `other` addresses
            return outs.filter { $0.address != address }.reduce(0) { $0 + $1.amount }
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

    func mapToTransactionRecord(transaction: Transaction, address: String) throws -> TransactionRecord {
        let isOutgoing = transaction.vin.contains(where: { $0.address == address })
        let sources: [TransactionRecord.Source] = transaction.vin.map {
            .init(address: $0.address, amount: Decimal($0.amount) / blockchain.decimalValue)
        }
        let destinations: [TransactionRecord.Destination] = transaction.vout.map {
            .init(address: .user($0.address), amount: Decimal($0.amount) / blockchain.decimalValue)
        }

        return TransactionRecord(
            hash: transaction.hash,
            index: 0,
            source: .from(sources),
            destination: .from(destinations),
            fee: .init(.init(with: blockchain, type: .coin, value: Decimal(transaction.fee) / blockchain.decimalValue)),
            status: .unconfirmed,
            isOutgoing: isOutgoing,
            type: .transfer,
            date: transaction.date,
            tokenTransfers: nil
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
        var address: String
        var amount: UInt64
    }

    typealias Output = Input
}
