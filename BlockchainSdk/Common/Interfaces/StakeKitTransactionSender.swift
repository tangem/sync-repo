//
//  StakeKitTransactionSender.swift
//  BlockchainSdk
//
//  Created by Sergey Balashov on 02.09.2024.
//

import Foundation

/// High-level protocol for preparing, signing and sending staking transactions
public protocol StakeKitTransactionSender {
    /// Return stream with tx which was sent one by one
    /// If catch error stream will be stopped
    /// In case when manager already implemented the `StakeKitTransactionSenderProvider` method will be not required
    func sendStakeKit(
        transactions: [StakeKitTransaction],
        signer: TransactionSigner,
        transactionStatusProvider: some StakeKitTransactionStatusProvider,
        delay second: UInt64?
    ) -> AsyncThrowingStream<StakeKitTransactionSendResult, Error>
}

// MARK: - Common implementation for StakeKitTransactionSenderProvider

extension StakeKitTransactionSender where Self: StakeKitTransactionsBuilder,
    Self: WalletProvider, RawTransaction: CustomStringConvertible,
    Self: StakeKitTransactionDataBroadcaster {
    func sendStakeKit(
        transactions: [StakeKitTransaction],
        signer: TransactionSigner,
        transactionStatusProvider: some StakeKitTransactionStatusProvider,
        delay: UInt64?
    ) -> AsyncThrowingStream<StakeKitTransactionSendResult, Error> {
        .init { [weak self] continuation in
            let task = Task { [weak self] in
                guard let self else {
                    continuation.finish()
                    return
                }

                do {
                    let rawTransactions = try await buildRawTransactions(
                        from: transactions,
                        publicKey: wallet.publicKey,
                        signer: signer
                    )

                    _ = try await withThrowingTaskGroup(
                        of: (TransactionSendResult, StakeKitTransaction).self
                    ) { group in
                        var results = [TransactionSendResult]()

                        for (index, (transaction, rawTransaction)) in zip(transactions, rawTransactions).enumerated() {
                            group.addTask {
                                let result: TransactionSendResult = try await self.broadcast(
                                    transaction: transaction,
                                    rawTransaction: rawTransaction,
                                    at: UInt64(index),
                                    delay: delay
                                )
                                return (result, transaction)
                            }

                            if transaction.requiresWaitingToComplete {
                                guard let result = try await group.next() else { continue }
                                results.append(result.0)

                                continuation.yield(.init(transaction: result.1, result: result.0))

                                try await self.waitForTransactionToComplete(
                                    transaction,
                                    transactionStatusProvider: transactionStatusProvider
                                )
                            }
                        }

                        for try await result in group where !results.contains(result.0) {
                            continuation.yield(.init(transaction: result.1, result: result.0))
                        }
                        return []
                    }

                    continuation.finish()

                } catch {
                    BSDKLogger.error("Staking transaction sent", error: error)
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { termination in
                task.cancel()
            }
        }
    }

    /// Convenience method with adding the `PendingTransaction` to the wallet  and `SendTxError` mapping
    private func broadcast(
        transaction: StakeKitTransaction,
        rawTransaction: RawTransaction,
        at index: UInt64,
        delay: UInt64? = nil
    ) async throws -> TransactionSendResult {
        try Task.checkCancellation()
        if index > 0, let delay {
            BSDKLogger.info("Start \(delay) second delay between the transactions sending")
            try await Task.sleep(nanoseconds: index * delay * NSEC_PER_SEC)
            try Task.checkCancellation()
        }

        do {
            let hash: String = try await broadcast(transaction: transaction, rawTransaction: rawTransaction)
            try Task.checkCancellation()
            let mapper = PendingTransactionRecordMapper()
            let record = mapper.mapToPendingTransactionRecord(
                stakeKitTransaction: transaction,
                source: wallet.defaultAddress.value,
                hash: hash
            )

            await addPendingTransaction(record)

            return TransactionSendResult(hash: hash)
        } catch {
            throw SendTxErrorFactory().make(error: error, with: rawTransaction.description)
        }
    }

    private func waitForTransactionToComplete(
        _ transaction: StakeKitTransaction,
        transactionStatusProvider: StakeKitTransactionStatusProvider
    ) async throws {
        var status: StakeKitTransaction.Status?
        let startPollingDate = Date()
        while status != .confirmed,
              Date().timeIntervalSince(startPollingDate) < StakeKitTransactionSenderConstants.pollingTimeout {
            try await Task.sleep(nanoseconds: StakeKitTransactionSenderConstants.pollingDelayInSeconds * NSEC_PER_SEC)
            status = try await transactionStatusProvider.transactionStatus(transaction)
        }
    }

    @MainActor
    private func addPendingTransaction(_ record: PendingTransactionRecord) {
        wallet.addPendingTransaction(record)
    }
}

extension StakeKitTransaction {
    var requiresWaitingToComplete: Bool {
        type == .split
    }
}

private enum StakeKitTransactionSenderConstants {
    static let pollingDelayInSeconds: UInt64 = 3
    static let pollingTimeout: TimeInterval = 30
}
