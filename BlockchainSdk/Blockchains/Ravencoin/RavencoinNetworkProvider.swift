//
//  RavencoinNetworkProvider.swift
//  BlockchainSdk
//
//  Created by Sergey Balashov on 03.04.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Moya
import Combine
import TangemFoundation

/// Documentations:
/// https://github.com/RavenDevKit/insight-api
/// https://github.com/RavenProject/Ravencoin/blob/master/doc/REST-interface.md
class RavencoinNetworkProvider: HostProvider {
    let host: String
    let provider: NetworkProvider<RavencoinTarget>

    private let blockchain = Blockchain.ravencoin(testnet: false)
    private var decimalValue: Decimal { blockchain.decimalValue }

    init(host: String, provider: NetworkProvider<RavencoinTarget>) {
        self.host = host
        self.provider = provider
    }
}

// MARK: - BitcoinNetworkProvider

extension RavencoinNetworkProvider: BitcoinNetworkProvider {
    var supportsTransactionPush: Bool { false }


    func getInfo(address: String) -> AnyPublisher<UTXOResponse, any Error> {
        getUTXO(address: address)
            .withWeakCaptureOf(self)
            .map { $0.mapToUnspentOutputs(outputs: $1) }
            .withWeakCaptureOf(self)
            .flatMap { provider, outputs in
                let pending = outputs.filter { !$0.isConfirmed }.map {
                    provider.getTxInfo(transactionId: $0.hash)
                }

                return Publishers.MergeMany(pending).collect()
                    .withWeakCaptureOf(provider)
                    .tryMap { provider, transactions in
                        try transactions.map { transaction in
                            try provider.mapToPendingTransactionRecord(transaction: transaction, walletAddress: address)
                        }
                    }
                    .map { UTXOResponse(outputs: outputs, pending: $0) }
            }
            .eraseToAnyPublisher()
    }

    func getFee() -> AnyPublisher<BitcoinFee, Error> {
        getFeeRatePerByte(blocks: 10)
            .tryMap { [weak self] perByte in
                guard let self else {
                    throw BlockchainSdkError.failedToLoadFee
                }

                // Increase rate just in case
                let perByte = perByte * 1.1
                let satoshi = perByte * decimalValue
                let minRate = satoshi
                let normalRate = satoshi * 12 / 10
                let priorityRate = satoshi * 15 / 10

                return BitcoinFee(
                    minimalSatoshiPerByte: minRate,
                    normalSatoshiPerByte: normalRate,
                    prioritySatoshiPerByte: priorityRate
                )
            }
            .eraseToAnyPublisher()
    }

    func send(transaction: String) -> AnyPublisher<String, Error> {
        send(transaction: RavencoinRawTransaction.Request(rawtx: transaction))
            .map { $0.txid }
            .eraseToAnyPublisher()
    }

    func push(transaction: String) -> AnyPublisher<String, Error> {
        .anyFail(error: BlockchainSdkError.networkProvidersNotSupportsRbf)
    }

    func getSignatureCount(address: String) -> AnyPublisher<Int, Error> {
        .anyFail(error: BlockchainSdkError.notImplemented)
    }
}

// MARK: - Mapping

private extension RavencoinNetworkProvider {
    func mapToUnspentOutputs(outputs: [RavencoinWalletUTXO]) -> [UnspentOutput] {
        outputs.map { utxo in
            UnspentOutput(blockId: utxo.height ?? -1, hash: utxo.txid, index: utxo.vout, amount: utxo.satoshis)
        }
    }

    func mapToPendingTransactionRecord(transaction: RavencoinTransactionInfo, walletAddress: String) throws -> PendingTransactionRecord {
        let isIncoming = transaction.vin.allSatisfy { $0.addr != walletAddress }
        let hash = transaction.txid
        let timestamp = transaction.time * 1000
        let fee = transaction.fees
        let value: Decimal

        if isIncoming {
            // Find all outputs to the our address
            let outputs = transaction.vout.filter {
                $0.scriptPubKey.addresses.contains { $0 == walletAddress }
            }

            value = outputs.compactMap { Decimal(stringValue: $0.value) }.reduce(0, +)

        } else {
            // Find all outputs from the our address
            let outputs = transaction.vout.filter {
                $0.scriptPubKey.addresses.contains { $0 != walletAddress }
            }

            value = outputs.compactMap { Decimal(stringValue: $0.value) }.reduce(0, +)
        }

        let otherAddresses = transaction.vout.filter {
            $0.scriptPubKey.addresses.contains { $0 != walletAddress }
        }

        guard let otherAddress = otherAddresses.first?.scriptPubKey.addresses.first else {
            throw WalletError.failedToParseNetworkResponse()
        }

        return PendingTransactionRecord(
            hash: hash,
            source: isIncoming ? otherAddress : walletAddress,
            destination: isIncoming ? walletAddress : otherAddress,
            amount: .init(with: blockchain, type: .coin, value: value),
            fee: .init(.init(with: blockchain, type: .coin, value: fee)),
            date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
            isIncoming: isIncoming,
            transactionType: .transfer,
            transactionParams: nil
        )
    }
}

// MARK: - Private

private extension RavencoinNetworkProvider {
    func getWalletInfo(address: String) -> AnyPublisher<RavencoinWalletInfo, Error> {
        provider
            .requestPublisher(.init(host: host, target: .wallet(address: address)))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(RavencoinWalletInfo.self)
            .eraseError()
    }

    func getTransactions(request: RavencoinTransactionHistory.Request) -> AnyPublisher<[RavencoinTransactionInfo], Error> {
        provider
            .requestPublisher(.init(host: host, target: .transactions(request: request)))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(RavencoinTransactionHistory.Response.self)
            .map { $0.txs }
            .eraseToAnyPublisher()
            .eraseError()
    }

    func getUTXO(address: String) -> AnyPublisher<[RavencoinWalletUTXO], Error> {
        provider
            .requestPublisher(.init(host: host, target: .utxo(address: address)))
            .filterSuccessfulStatusAndRedirectCodes()
            .map([RavencoinWalletUTXO].self)
            .eraseError()
    }

    func getFeeRatePerByte(blocks: Int) -> AnyPublisher<Decimal, Error> {
        provider
            .requestPublisher(.init(host: host, target: .fees(request: .init(nbBlocks: blocks))))
            .filterSuccessfulStatusAndRedirectCodes()
            .mapJSON(failsOnEmptyData: true)
            .tryMap { json throws -> Decimal in
                guard let json = json as? [String: Any],
                      let rate = json["\(blocks)"] as? Double else {
                    throw BlockchainSdkError.failedToLoadFee
                }

                let ratePerKilobyte = Decimal(floatLiteral: rate)
                return ratePerKilobyte / 1024
            }
            .eraseToAnyPublisher()
    }

    func getTxInfo(transactionId: String) -> AnyPublisher<RavencoinTransactionInfo, Error> {
        provider
            .requestPublisher(.init(host: host, target: .transaction(id: transactionId)))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(RavencoinTransactionInfo.self)
            .eraseError()
    }

    func send(transaction: RavencoinRawTransaction.Request) -> AnyPublisher<RavencoinRawTransaction.Response, Error> {
        provider
            .requestPublisher(.init(host: host, target: .send(transaction: transaction)))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(RavencoinRawTransaction.Response.self)
            .eraseToAnyPublisher()
            .eraseError()
    }
}
