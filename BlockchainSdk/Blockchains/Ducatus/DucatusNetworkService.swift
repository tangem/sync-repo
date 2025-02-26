//
//  DucatusNetworkService.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 17.02.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import Moya

class DucatusNetworkService: BitcoinNetworkProvider {
    private let provider: BitcoreProvider

    var host: String { provider.host }
    var supportsTransactionPush: Bool { false }

    init(configuration: NetworkProviderConfiguration) {
        provider = BitcoreProvider(configuration: configuration)
    }

    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], any Error> {
        provider.getUnspents(address: address)
            .withWeakCaptureOf(self)
            .map { $0.mapToUnspentOutputs(outputs: $1) }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    func getTransactionInfo(hash: String, address: String) -> AnyPublisher<TransactionRecord, any Error> {
        // TODO: https://github.com/bitpay/bitcore/blob/master/packages/bitcore-node/docs/api-documentation.md#get-transaction-by-txid
        Empty().eraseToAnyPublisher()
    }

    func getInfo(address: String) -> AnyPublisher<BitcoinResponse, Error> {
        return Publishers.Zip(provider.getBalance(address: address), provider.getUnspents(address: address))
            .tryMap { balance, unspents throws -> BitcoinResponse in
                guard let confirmed = balance.confirmed,
                      let unconfirmed = balance.unconfirmed else {
                    throw WalletError.failedToParseNetworkResponse()
                }

                let utxs: [BitcoinUnspentOutput] = unspents.compactMap { utxo -> BitcoinUnspentOutput? in
                    guard let hash = utxo.mintTxid,
                          let n = utxo.mintIndex,
                          let val = utxo.value,
                          let script = utxo.script else {
                        return nil
                    }

                    let btx = BitcoinUnspentOutput(transactionHash: hash, outputIndex: n, amount: UInt64(val), outputScript: script)
                    return btx
                }

                let balance = Decimal(confirmed) / Blockchain.ducatus.decimalValue
                return BitcoinResponse(balance: balance, hasUnconfirmed: unconfirmed != 0, pendingTxRefs: [], unspentOutputs: utxs)
            }
            .eraseToAnyPublisher()
    }

    func send(transaction: String) -> AnyPublisher<String, Error> {
        return provider.send(transaction)
            .tryMap { response throws -> String in
                if let id = response.txid {
                    return id
                } else {
                    throw WalletError.failedToParseNetworkResponse()
                }
            }.eraseToAnyPublisher()
    }

    func getFee() -> AnyPublisher<BitcoinFee, Error> {
        let fee = BitcoinFee(
            minimalSatoshiPerByte: 89,
            normalSatoshiPerByte: 144,
            prioritySatoshiPerByte: 350
        )

        return Just(fee)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

extension DucatusNetworkService {
    func mapToUnspentOutputs(outputs: [BitcoreUtxo]) -> [UnspentOutput] {
        outputs.compactMap { output -> UnspentOutput? in
            guard let hash = output.mintTxid,
                  let index = output.mintIndex,
                  let value = output.value else {
                return nil
            }

            // All confirmed
            return UnspentOutput(blockId: 1, hash: hash, index: index, amount: UInt64(value))
        }
    }
}
