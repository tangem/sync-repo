//
//  BitcoinNetworkProvider.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 07.04.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine

// Confirm by BlockBook, Blockchair, Blockcyper etc.
protocol BitcoinNetworkProvider: AnyObject, HostProvider {
    var supportsTransactionPush: Bool { get }

    func getInfo(address: String) -> AnyPublisher<UTXOResponse, Error>
    func getFee() -> AnyPublisher<BitcoinFee, Error>
    func send(transaction: String) -> AnyPublisher<String, Error>
    func push(transaction: String) -> AnyPublisher<String, Error>
    func getSignatureCount(address: String) -> AnyPublisher<Int, Error>
}

extension BitcoinNetworkProvider {
    func eraseToAnyBitcoinNetworkProvider() -> AnyBitcoinNetworkProvider {
        AnyBitcoinNetworkProvider(self)
    }
}

// Typeerasurer because of compiler behaviour
class AnyBitcoinNetworkProvider: BitcoinNetworkProvider {
    var supportsTransactionPush: Bool { provider.supportsTransactionPush }
    var host: String { provider.host }

    private let provider: BitcoinNetworkProvider

    init<P: BitcoinNetworkProvider>(_ provider: P) {
        self.provider = provider
    }

    func getInfo(address: String) -> AnyPublisher<UTXOResponse, any Error> {
        provider.getInfo(address: address)
    }

    func getFee() -> AnyPublisher<BitcoinFee, Error> {
        provider.getFee()
    }

    func send(transaction: String) -> AnyPublisher<String, Error> {
        provider.send(transaction: transaction)
    }

    func push(transaction: String) -> AnyPublisher<String, Error> {
        provider.push(transaction: transaction)
    }

    func getSignatureCount(address: String) -> AnyPublisher<Int, Error> {
        provider.getSignatureCount(address: address)
    }
}

struct UTXOResponse {
    let outputs: [UnspentOutput]
    let pending: [PendingTransactionRecord]

    init(outputs: [UnspentOutput], pending: [PendingTransactionRecord]) {
        self.outputs = outputs
        self.pending = pending
    }
}
