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

    // MARK: - Init

    init(provider: ElectrumWebSocketProvider) {
        self.provider = provider
    }

    // MARK: - BitcoinNetworkProvider Implementation

    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], any Error> {
        Future.async {
            let scriptHash = try Fact0rnAddressService.addressToScriptHash(address: address)
            let unspents = try await self.provider.getUnspents(identifier: .scriptHash(scriptHash))
            return self.mapUnspent(outputs: unspents)
        }
        .eraseToAnyPublisher()
    }

    func getTransactionInfo(hash: String, address: String) -> AnyPublisher<TransactionRecord, any Error> {
        Future.async {
            let transaction = try await self.provider.getTransaction(hash: hash)
            return try self.mapToTransactionRecord(transaction: transaction, address: address)
        }
        .eraseToAnyPublisher()
    }

    func getInfo(address: String) -> AnyPublisher<BitcoinResponse, any Error> {
        return Result { try Fact0rnAddressService.addressToScriptHash(address: address) }
            .publisher
            .withWeakCaptureOf(self)
            .flatMap { provider, scriptHash in
                provider.getAddressInfo(identifier: .scriptHash(scriptHash))
            }
            .withWeakCaptureOf(self)
            .tryMap { provider, accountInfo in
                let outputScriptData = try Fact0rnAddressService.addressToScript(address: address).scriptData

                return try provider.mapBitcoinResponse(
                    account: accountInfo,
                    outputScript: outputScriptData.hexString
                )
            }
            .eraseToAnyPublisher()
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

    // MARK: - Private Implementation

    private func getAddressInfo(identifier: ElectrumWebSocketProvider.Identifier) -> AnyPublisher<ElectrumAddressInfo, Error> {
        Future.async {
            async let balance = self.provider.getBalance(identifier: identifier)
            async let unspents = self.provider.getUnspents(identifier: identifier)

            return try await ElectrumAddressInfo(
                balance: Decimal(balance.confirmed) / self.blockchain.decimalValue,
                unconfirmed: Decimal(balance.unconfirmed) / self.blockchain.decimalValue,
                outputs: unspents.map { unspent in
                    ElectrumUTXO(
                        position: unspent.txPos,
                        hash: unspent.txHash,
                        value: unspent.value,
                        height: unspent.height
                    )
                }
            )
        }
        .eraseToAnyPublisher()
    }

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

    // MARK: - Helpers

    private func mapBitcoinResponse(account: ElectrumAddressInfo, outputScript: String) throws -> BitcoinResponse {
        let hasUnconfirmed = account.unconfirmed != .zero
        let unspentOutputs = mapUnspent(outputs: account.outputs, outputScript: outputScript)

        return BitcoinResponse(
            balance: account.balance,
            hasUnconfirmed: hasUnconfirmed,
            pendingTxRefs: [],
            unspentOutputs: unspentOutputs
        )
    }

    private func mapUnspent(outputs: [ElectrumUTXO], outputScript: String) -> [BitcoinUnspentOutput] {
        outputs.map {
            BitcoinUnspentOutput(
                transactionHash: $0.hash,
                outputIndex: $0.position,
                amount: $0.value.uint64Value,
                outputScript: outputScript
            )
        }
    }
}

extension Fact0rnNetworkProvider {
    private func mapToTransactionRecord(transaction: ElectrumDTO.Response.Transaction, address: String) throws -> TransactionRecord {
        guard let fee = transaction.feeSatoshi else {
            throw ProviderError.fieldNotFound("feeSatoshi")
        }

        return try UTXOPendingTransactionMapper(blockchain: blockchain).mapToTransactionRecord(
            transaction: .init(
                hash: transaction.hash,
                fee: fee.uint64Value,
                date: transaction.time.map { Date(timeIntervalSince1970: TimeInterval($0)) } ?? Date(),
                vin: transaction.vin.map { .init(address: $0.address, amount: UInt64($0.vout)) }, // TODO: Amount VIN
                vout: transaction.vout.map { .init(address: $0.scriptPubKey.addresses.first ?? .unknown, amount: $0.value.uint64Value) }
            ),
            address: address
        )
    }

    private func mapUnspent(outputs: [ElectrumDTO.Response.ListUnspent]) -> [UnspentOutput] {
        outputs.map {
            UnspentOutput(blockId: $0.height.intValue(), hash: $0.txHash, index: $0.txPos, amount: $0.value.uint64Value)
        }
    }
}

extension Fact0rnNetworkProvider {
    enum ProviderError: LocalizedError {
        case failedScriptHashForAddress
        case fieldNotFound(String)
    }

    enum Constants {
        static let minimalFeeBlockAmount = 8
        static let normalFeeBlockAmount = 4
        static let priorityFeeBlockAmount = 1

        /// We use 1000, because Electrum node return fee for per 1000 bytes.
        static let perKbRate: Decimal = 1000
    }
}
