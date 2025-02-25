//
//  BlockBookUTXOProvider.swift
//  BlockchainSdk
//
//  Created by Pavel Grechikhin on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import TangemFoundation
import CombineExt

/// Documentation: https://github.com/trezor/blockbook/blob/master/docs/api.md
class BlockBookUTXOProvider {
    var host: String {
        "\(blockchain.currencySymbol.lowercased()).\(config.host)"
    }

    private let blockchain: Blockchain
    private let config: BlockBookConfig
    private let provider: NetworkProvider<BlockBookTarget>

    private var decimalValue: Decimal {
        blockchain.decimalValue
    }

    init(
        blockchain: Blockchain,
        blockBookConfig: BlockBookConfig,
        networkConfiguration: NetworkProviderConfiguration
    ) {
        self.blockchain = blockchain
        config = blockBookConfig
        provider = NetworkProvider<BlockBookTarget>(configuration: networkConfiguration)
    }

    /// https://docs.syscoin.org/docs/dev-resources/documentation/javascript-sdk-ref/blockbook/#get-utxo
    func unspentTxData(address: String) -> AnyPublisher<[BlockBookUnspentTxResponse], Error> {
        executeRequest(.utxo(address: address), responseType: [BlockBookUnspentTxResponse].self)
    }

    func transactionInfo(hash: String) -> AnyPublisher<BlockBookAddressResponse.Transaction, Error> {
        executeRequest(.txDetails(txHash: hash), responseType: BlockBookAddressResponse.Transaction.self)
    }

    func addressData(address: String, parameters: BlockBookTarget.AddressRequestParameters) -> AnyPublisher<BlockBookAddressResponse, Error> {
        executeRequest(.address(address: address, parameters: parameters), responseType: BlockBookAddressResponse.self)
    }

    func getFeeRatePerByte(for confirmationBlocks: Int) -> AnyPublisher<Decimal, Error> {
        switch blockchain {
        case .clore:
            executeRequest(.getFees(confirmationBlocks: confirmationBlocks), responseType: BlockBookFeeResultResponse.self)
                .withWeakCaptureOf(self)
                .tryMap { provider, response in
                    guard let decimalFeeResult = Decimal(stringValue: response.result) else {
                        throw WalletError.failedToGetFee
                    }

                    return try provider.convertFeeRate(decimalFeeResult)
                }.eraseToAnyPublisher()
        default:
            executeRequest(.fees(NodeRequest.estimateFeeRequest(confirmationBlocks: confirmationBlocks)), responseType: BlockBookFeeRateResponse.self)
                .withWeakCaptureOf(self)
                .tryMap { provider, response in
                    try provider.convertFeeRate(Decimal(response.result.feerate))
                }.eraseToAnyPublisher()
        }
    }

    func sendTransaction(hex: String) -> AnyPublisher<String, Error> {
        guard let transactionData = hex.data(using: .utf8) else {
            return .anyFail(error: WalletError.failedToSendTx)
        }

        return executeRequest(.sendBlockBook(tx: transactionData), responseType: SendResponse.self)
            .map { $0.result }
            .eraseToAnyPublisher()
    }

    func convertFeeRate(_ fee: Decimal) throws -> Decimal {
        if fee <= 0 {
            throw BlockchainSdkError.failedToLoadFee
        }

        // estimatesmartfee returns fee in currency per kilobyte
        let bytesInKiloByte: Decimal = 1024
        let feeRatePerByte = fee * decimalValue / bytesInKiloByte

        return feeRatePerByte.rounded(roundingMode: .up)
    }

    // TODO: Move to private
    // https://tangem.atlassian.net/browse/IOS-9232
    func executeRequest<T: Decodable>(_ request: BlockBookTarget.Request, responseType: T.Type) -> AnyPublisher<T, Error> {
        provider
            .requestPublisher(target(for: request))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(T.self)
            .eraseError()
            .eraseToAnyPublisher()
    }
}

// MARK: - Private

private extension BlockBookUTXOProvider {
    func target(for request: BlockBookTarget.Request) -> BlockBookTarget {
        BlockBookTarget(request: request, config: config, blockchain: blockchain)
    }

    func mapBitcoinFee(_ feeRatePublishers: [AnyPublisher<Decimal, Error>]) -> AnyPublisher<BitcoinFee, Error> {
        Publishers.MergeMany(feeRatePublishers)
            .collect()
            .map { $0.sorted() }
            .tryMap { fees -> BitcoinFee in
                guard fees.count == feeRatePublishers.count else {
                    throw BlockchainSdkError.failedToLoadFee
                }

                return BitcoinFee(
                    minimalSatoshiPerByte: fees[0],
                    normalSatoshiPerByte: fees[1],
                    prioritySatoshiPerByte: fees[2]
                )
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - BitcoinNetworkProvider

extension BlockBookUTXOProvider: BitcoinNetworkProvider {
    var supportsTransactionPush: Bool { false }

    func getInfo(address: String) -> AnyPublisher<UTXOResponse, any Error> {
        getUnspentOutputs(address: address)
            .withWeakCaptureOf(self)
            .flatMap { provider, outputs in
                let pendings = outputs.filter { !$0.isConfirmed }.map { output in
                    provider.getInfo(transaction: output.hash, address: address)
                }

                return Publishers.MergeMany(pendings).collect().map {
                    UTXOResponse(outputs: outputs, pending: $0)
                }
            }
            .eraseToAnyPublisher()
    }

    func getInfo(transaction: String, address: String) -> AnyPublisher<PendingTransactionRecord, any Error> {
        transactionInfo(hash: transaction)
            .withWeakCaptureOf(self)
            .tryMap { try $0.mapToPendingTransaction(transaction: $1, address: address) }
            .eraseToAnyPublisher()
    }

    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], any Error> {
        unspentTxData(address: address).map { utxos in
            utxos.compactMap { utxo -> UnspentOutput? in
                guard let value = UInt64(utxo.value) else {
                    return nil
                }

                // From documentation:
                // Unconfirmed utxos do not have field height, the field confirmations has value 0 and may contain field lockTime, if not zero.
                return UnspentOutput(blockId: utxo.height ?? 0, hash: utxo.txid, index: utxo.vout, amount: value)
            }
        }
        .eraseToAnyPublisher()
    }

    func getFee() -> AnyPublisher<BitcoinFee, Error> {
        // Number of blocks we want the transaction to be confirmed in.
        // The lower the number the bigger the fee returned by 'estimatesmartfee'.
        let confirmationBlocks = [8, 4, 1]

        return mapBitcoinFee(
            confirmationBlocks.map {
                getFeeRatePerByte(for: $0)
            }
        )
    }

    func send(transaction: String) -> AnyPublisher<String, Error> {
        sendTransaction(hex: transaction)
    }

    func push(transaction: String) -> AnyPublisher<String, Error> {
        .anyFail(error: "RBF not supported")
    }

    func getSignatureCount(address: String) -> AnyPublisher<Int, Error> {
        addressData(address: address, parameters: .init(details: [.txs]))
            .tryMap { response in
                let outgoingTxsCount = response.transactions?.filter { transaction in
                    return transaction.compat.vin.contains(where: { inputs in
                        inputs.addresses.contains(address)
                    })
                }.count ?? 0
                return outgoingTxsCount
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Mapping

private extension BlockBookUTXOProvider {
    func mapToPendingTransaction(transaction: BlockBookAddressResponse.Transaction, address: String) throws -> PendingTransactionRecord {
        guard let fee = Decimal(stringValue: transaction.fees) else {
            throw WalletError.failedToParseNetworkResponse()
        }

        return try UTXOPendingTransactionMapper(blockchain: blockchain).mapPendingTransactionRecord(
            transaction: .init(
                hash: transaction.txid,
                fee: fee.uint64Value,
                date: Date(timeIntervalSince1970: TimeInterval(transaction.blockTime)),
                vin: transaction.compat.vin.compactMap { vin in
                    Decimal(stringValue: vin.value).map {
                        .init(addresses: vin.addresses, amount: $0.uint64Value)
                    }
                },
                vout: transaction.compat.vout.compactMap { vout in
                    Decimal(stringValue: vout.value).map {
                        .init(addresses: vout.addresses, amount: $0.uint64Value)
                    }
                }
            ),
            address: address
        )
    }
}
