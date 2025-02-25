//
//  Fact0rnNetworkProvider.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 31.12.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import Combine

final class Fact0rnNetworkProvider: BitcoinNetworkProvider {
    // MARK: - Properties

    var supportsTransactionPush: Bool { false }
    var host: String { provider.host }

    // MARK: - Private Properties

    private let provider: ElectrumWebSocketProvider
    private let blockchain: Blockchain = .fact0rn
    private let mapper = UTXOPendingTransactionMapper(blockchain: .fact0rn)

    // MARK: - Init

    init(provider: ElectrumWebSocketProvider) {
        self.provider = provider
    }

    // MARK: - BitcoinNetworkProvider Implementation

    func getInfo(address: String) -> AnyPublisher<UTXOResponse, any Error> {
        Future.async {
            let scriptHash = Result { try Fact0rnAddressService.addressToScriptHash(address: address) }
            let unspents = try await self.provider.getUnspents(identifier: .scriptHash(scriptHash.get()))
            let outputs = self.mapUnspent(outputs: unspents)

            let unconfirmed = try await outputs.filter { !$0.isConfirmed }.asyncMap { output in
                let transaction = try await self.provider.getTransaction(hash: output.hash)
                return try self.mapToPendingTransactionRecord(transaction: transaction, address: address)
            }

            return UTXOResponse(outputs: outputs, pending: unconfirmed)
        }
        .eraseToAnyPublisher()
//
//        return scriptHash
//            .publisher
//            .withWeakCaptureOf(self)
//            .flatMap { provider, scriptHash in
//                provider.getAddressInfo(identifier: .scriptHash(scriptHash))
//            }
//            .withWeakCaptureOf(self)
//            .tryMap { provider, accountInfo in
//                let outputScriptData = try scriptHash.get()
//
//                return try provider.mapToUTXOResponse(account: accountInfo, outputScript: outputScriptData)
//            }
//            .eraseToAnyPublisher()
    }

    func getFee() -> AnyPublisher<BitcoinFee, any Error> {
        let minimalEstimateFeePublisher = estimateFee(confirmation: Constants.minimalFeeBlockAmount)
        let normalEstimateFeePublisher = estimateFee(confirmation: Constants.normalFeeBlockAmount)
        let priorityEstimateFeePublisher = estimateFee(confirmation: Constants.priorityFeeBlockAmount)

        return Publishers.Zip3(
            minimalEstimateFeePublisher,
            normalEstimateFeePublisher,
            priorityEstimateFeePublisher
        )
        .withWeakCaptureOf(self)
        .map { provider, values in
            let minimalSatoshiPerByte = values.0 / Constants.perKbRate
            let normalSatoshiPerByte = values.1 / Constants.perKbRate
            let prioritySatoshiPerByte = values.2 / Constants.perKbRate

            return (minimalSatoshiPerByte, normalSatoshiPerByte, prioritySatoshiPerByte)
        }
        .withWeakCaptureOf(self)
        .map { provider, values in
            return BitcoinFee(
                minimalSatoshiPerByte: values.0,
                normalSatoshiPerByte: values.1,
                prioritySatoshiPerByte: values.2
            )
        }
        .eraseToAnyPublisher()
    }

    func send(transaction: String) -> AnyPublisher<String, any Error> {
        Future.async {
            return try await self.provider.send(transactionHex: transaction)
        }
        .eraseToAnyPublisher()
    }

    func push(transaction: String) -> AnyPublisher<String, any Error> {
        assertionFailure("This method marked as deprecated")
        return .anyFail(error: BlockchainSdkError.noAPIInfo)
    }

    func getSignatureCount(address: String) -> AnyPublisher<Int, any Error> {
        Future.async {
            let txHistory = try await self.provider.getTxHistory(identifier: .scriptHash(address))
            return txHistory.count
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private Implementation

//    private func getAddressInfo(identifier: ElectrumWebSocketProvider.Identifier) -> AnyPublisher<ElectrumAddressInfo, Error> {
//        Future.async {
//            async let balance = self.provider.getBalance(identifier: identifier)
//            async let unspents = self.provider.getUnspents(identifier: identifier)
//
//            return try await ElectrumAddressInfo(
//                balance: Decimal(balance.confirmed) / self.decimalValue,
//                unconfirmed: Decimal(balance.unconfirmed) / self.decimalValue,
//                outputs: unspents.map { unspent in
//                    ElectrumUTXO(
//                        position: unspent.txPos,
//                        hash: unspent.txHash,
//                        value: unspent.value,
//                        height: unspent.height
//                    )
//                }
//            )
//        }
//        .eraseToAnyPublisher()
//    }

    private func estimateFee(confirmation blocks: Int) -> AnyPublisher<Decimal, Error> {
        Future.async {
            try await self.provider.estimateFee(block: blocks)
        }
        .eraseToAnyPublisher()
    }

    private func send(transactionHex: String) -> AnyPublisher<String, Error> {
        Future.async {
            try await self.provider.send(transactionHex: transactionHex)
        }
        .eraseToAnyPublisher()
    }

    private func getTransactionInfo(hash: String) -> AnyPublisher<ElectrumDTO.Response.Transaction, Error> {
        Future.async {
            try await self.provider.getTransaction(hash: hash)
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Helpers

    private func mapToPendingTransactionRecord(transaction: ElectrumDTO.Response.Transaction, address: String) throws -> PendingTransactionRecord {
        try mapper.mapPendingTransactionRecord(
            transaction: .init(
                hash: transaction.hash,
                fee: transaction.feeSatoshi,
                date: transaction.time.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? Date(),
                vin: transaction.vin.map { .init(addresses: [$0.address], amount: UInt64($0.vout)) }, // TODO: Amount VIN
                vout: transaction.vout.map { .init(addresses: $0.scriptPubKey.addresses, amount: $0.value.uint64Value) }
            ),
            address: address
        )
    }

    private func mapUnspent(outputs: [ElectrumDTO.Response.ListUnspent]) -> [UnspentOutput] {
        outputs.map {
            UnspentOutput(blockId: $0.height, hash: $0.txHash, index: $0.txPos, amount: $0.value)
        }
    }
}

extension Fact0rnNetworkProvider {
    enum ProviderError: LocalizedError {
        case failedScriptHashForAddress
    }

    enum Constants {
        static let minimalFeeBlockAmount = 8
        static let normalFeeBlockAmount = 4
        static let priorityFeeBlockAmount = 1

        /// We use 1000, because Electrum node return fee for per 1000 bytes.
        static let perKbRate: Decimal = 1000
    }
}
