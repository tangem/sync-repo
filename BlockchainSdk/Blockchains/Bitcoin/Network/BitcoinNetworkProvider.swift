//
//  BitcoinNetworkProvider.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 07.04.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine

@available(*, deprecated, renamed: "UTXONetworkProvider", message: "Use UTXONetworkProvider")
protocol BitcoinNetworkProvider: AnyObject, HostProvider {
    func getInfo(address: String) -> AnyPublisher<UTXOResponse, Error>
    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], Error>
    func getTransactionInfo(hash: String, address: String) -> AnyPublisher<TransactionRecord, Error>

    func getInfo(addresses: [String]) -> AnyPublisher<[BitcoinResponse], Error>
    func getInfo(address: String) -> AnyPublisher<BitcoinResponse, Error>
    func getFee() -> AnyPublisher<BitcoinFee, Error>
    func send(transaction: String) -> AnyPublisher<String, Error>
}

extension BitcoinNetworkProvider {
    func getInfo(addresses: [String]) -> AnyPublisher<[BitcoinResponse], Error> {
        .multiAddressPublisher(addresses: addresses, requestFactory: { [weak self] in
            self?.getInfo(address: $0) ?? .emptyFail
        })
    }

    // Default implementation
    func getInfo(address: String) -> AnyPublisher<UTXOResponse, any Error> {
        getUnspentOutputs(address: address)
            .withWeakCaptureOf(self)
            .flatMap { provider, outputs in
                let pending = outputs.filter { $0.isConfirmed }.map {
                    provider.getTransactionInfo(hash: $0.hash, address: address)
                }

                return Publishers.MergeMany(pending).collect()
                    .withWeakCaptureOf(provider)
                    .tryMap { provider, transactions in
                        UTXOResponse(outputs: outputs, pending: transactions)
                    }
            }
            .eraseToAnyPublisher()
    }

    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], Error> {
        Empty().eraseToAnyPublisher()
    }

    func getTransactionInfo(hash: String, address: String) -> AnyPublisher<TransactionRecord, Error> {
        Empty().eraseToAnyPublisher()
    }

    func eraseToAnyBitcoinNetworkProvider() -> AnyBitcoinNetworkProvider {
        AnyBitcoinNetworkProvider(self)
    }
}

class AnyBitcoinNetworkProvider: BitcoinNetworkProvider {
    var host: String { provider.host }

    private let provider: BitcoinNetworkProvider

    init<P: BitcoinNetworkProvider>(_ provider: P) {
        self.provider = provider
    }

    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], any Error> {
        provider.getUnspentOutputs(address: address)
    }

    func getTransactionInfo(hash: String, address: String) -> AnyPublisher<TransactionRecord, any Error> {
        provider.getTransactionInfo(hash: hash, address: address)
    }

    func getInfo(address: String) -> AnyPublisher<BitcoinResponse, Error> {
        provider.getInfo(address: address)
    }

    func getFee() -> AnyPublisher<BitcoinFee, Error> {
        provider.getFee()
    }

    func send(transaction: String) -> AnyPublisher<String, Error> {
        provider.send(transaction: transaction)
    }
}
