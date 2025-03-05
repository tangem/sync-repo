//
//  KaspaTransactionHistoryMapper.swift
//  TangemApp
//
//  Created by Dmitry Fedorov on 04.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

final class KaspaTransactionHistoryMapper {
    private let blockchain: Blockchain

    init(blockchian: Blockchain) {
        blockchain = blockchian
    }

    private func extractTransactionAmount(
        transaction: KaspaTransactionHistoryResponse.Transaction,
        isOutgoing: Bool,
        fee: Int,
        walletAddress: String
    ) -> Decimal? {
        let amount = if isOutgoing {
            transaction.outputs.first(where: { $0.scriptPublicKeyAddress != walletAddress })?.amount
        } else {
            transaction.outputs.first(where: { $0.scriptPublicKeyAddress == walletAddress })?.amount
        }

        guard let amount else { return nil }

        let amountWithFee = if isOutgoing {
            amount + fee
        } else {
            amount
        }

        return Decimal(amountWithFee) / blockchain.decimalValue
    }

    private func extractDestination(
        transaction: KaspaTransactionHistoryResponse.Transaction,
        isOutgoing: Bool,
        amount: Decimal,
        walletAddress: String
    ) -> TransactionRecord.DestinationType? {
        if isOutgoing {
            let outputAddresses = transaction.outputs
                .filter { $0.scriptPublicKeyAddress != walletAddress }
                .map { TransactionRecord.Destination(address: .user($0.scriptPublicKeyAddress), amount: amount) }

            switch outputAddresses.count {
            case 0: return nil
            case 1:
                guard let firstAddress = outputAddresses.first else { return nil }
                return .single(firstAddress)
            default:
                return .multiple(outputAddresses)
            }
        } else {
            return TransactionRecord.DestinationType.single(.init(address: .user(walletAddress), amount: amount))
        }
    }

    private func extractSource(
        transaction: KaspaTransactionHistoryResponse.Transaction,
        amount: Decimal,
        isOutgoing: Bool,
        walletAddress: String
    ) -> TransactionRecord.SourceType? {
        if isOutgoing {
            .single(.init(address: walletAddress, amount: amount))
        } else {
            transaction.inputs
                .first { $0.previousOutpointAddress != walletAddress }
                .flatMap { .single(.init(address: $0.previousOutpointAddress, amount: amount)) }
        }
    }
}

// MARK: - TransactionHistoryMapper protocol conformance

extension KaspaTransactionHistoryMapper: TransactionHistoryMapper {
    func mapToTransactionRecords(
        _ response: KaspaTransactionHistoryResponse,
        walletAddress: String,
        amountType: Amount.AmountType
    ) throws -> [TransactionRecord] {
        let transactions = response.transactions

        return transactions.compactMap { transaction -> TransactionRecord? in
            let isOutgoing = transaction.inputs.contains(where: { $0.previousOutpointAddress == walletAddress })

            let fee = transaction.inputs.map(\.previousOutpointAmount).reduce(0, +) - transaction.outputs.map(\.amount).reduce(0, +)

            guard let amount = extractTransactionAmount(
                transaction: transaction,
                isOutgoing: isOutgoing,
                fee: fee,
                walletAddress: walletAddress
            ) else {
                return nil
            }

            guard let destination = extractDestination(
                transaction: transaction,
                isOutgoing: isOutgoing,
                amount: amount,
                walletAddress: walletAddress
            ) else {
                return nil
            }

            guard let source = extractSource(
                transaction: transaction,
                amount: amount,
                isOutgoing: isOutgoing,
                walletAddress: walletAddress
            ) else { return nil }

            return TransactionRecord(
                hash: transaction.hash,
                index: 0,
                source: source,
                destination: destination,
                fee: Fee(Amount(with: blockchain, value: Decimal(fee))),
                status: transaction.isAccepted ? .confirmed : .unconfirmed,
                isOutgoing: isOutgoing,
                type: .transfer,
                date: transaction.blockTime
            )
        }
    }

    func reset() {}
}

// MARK: - Constants

private extension KaspaTransactionHistoryMapper {
    enum Constants {
        static let maxRateLimitReachedResultPrefix = "max rate limit reached"
        /// Method names in the API look like `swap(address executor,tuple desc,bytes permit,bytes data)`,
        /// so we have to remove all method signatures (parameters, types, etc).
        static let methodNameSeparator = "("
    }
}

// MARK: - Convenience extensions

private extension KaspaTransactionHistoryResponse.Transaction {
    var isContractInteraction: Bool {
        false
    }
}
