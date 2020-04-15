//
//  Bitcoin.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 06.12.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import Combine
import RxSwift

enum BitcoinError: Error {
    case noUnspents
    case failedToBuildHash
    case failedToBuildTransaction
    case failedToMapNetworkResponse
    case failedToCalculateTxSize
}

class BitcoinWalletManager: WalletManager<CurrencyWallet> {
    var txBuilder: BitcoinTransactionBuilder!
    var network: BitcoinNetworkProvider!
    override func update() {
        requestDisposable = network.getInfo()
        .subscribe( onSuccess: { response in
                self.updateWallet(with: response)
        }, onError: { error in
            self.onError.onNext(error)
        })
    }
    
    @available(iOS 13.0, *)
    func getFee(amount: Amount, source: String, destination: String) -> AnyPublisher<[Amount], Error> {
        return network.getFee()
            .tryMap {[unowned self] response throws -> [Amount] in
                let kb = Decimal(1024)
                let minPerByte = response.minimalKb/kb
                let normalPerByte = response.normalKb/kb
                let maxPerByte = response.priorityKb/kb
                
                guard let estimatedTxSize = self.getEstimateSize(for: Transaction(amount: amount, fee: Amount(with: amount, value: 0.0001), sourceAddress: source, destinationAddress: destination)) else {
                    throw BitcoinError.failedToCalculateTxSize
                }
                
                let minFee = (minPerByte * estimatedTxSize)
                let normalFee = (normalPerByte * estimatedTxSize)
                let maxFee = (maxPerByte * estimatedTxSize)
                return [
                    Amount(with: self.wallet.blockchain, address: source, value: minFee),
                    Amount(with: self.wallet.blockchain, address: source, value: normalFee),
                    Amount(with: self.wallet.blockchain, address: source, value: maxFee)
                ]
        }
        .eraseToAnyPublisher()
    }
    
    //TODO: rename
    private func updateWallet(with response: BitcoinResponse) {
        wallet.add(coinValue: response.balance)
        txBuilder.unspentOutputs = response.txrefs
        if response.hasUnconfirmed {
            if wallet.pendingTransactions.isEmpty {
                wallet.addIncomingTransaction()
            }
        } else {
            wallet.pendingTransactions = []
        }
       walletDidUpdate()
    }
    
    private func getEstimateSize(for transaction: Transaction) -> Decimal? {
        guard let unspentOutputsCount = txBuilder.unspentOutputs?.count else {
            return nil
        }
        
        guard let tx = txBuilder.buildForSend(transaction: transaction, signature: Data(repeating: UInt8(0x01), count: 64 * unspentOutputsCount)) else {
            return nil
        }
        
        return Decimal(tx.count + 1)
    }
}


@available(iOS 13.0, *)
extension BitcoinWalletManager: TransactionSender {
    func send(_ transaction: Transaction, signer: TransactionSigner) -> AnyPublisher<Bool, Error> {
        guard let hashes = txBuilder.buildForSign(transaction: transaction) else {
            return Fail(error: BitcoinError.failedToBuildHash).eraseToAnyPublisher()
        }
        
        return signer.sign(hashes: hashes, cardId: cardId)
            .tryMap {[unowned self] response in
                guard let tx = self.txBuilder.buildForSend(transaction: transaction, signature: response.signature) else {
                    throw BitcoinError.failedToBuildTransaction
                }
                return tx.toHexString()
        }
        .flatMap {[unowned self] in
            self.network.send(transaction: $0).map {[unowned self] response in
                self.wallet.add(transaction: transaction)
                self.walletDidUpdate()
                return true
            }
        }
        .eraseToAnyPublisher()
    }
}

extension BitcoinWalletManager: ThenProcessable { }
