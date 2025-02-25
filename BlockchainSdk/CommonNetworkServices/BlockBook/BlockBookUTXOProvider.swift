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

/// Documentation: https://github.com/trezor/blockbook/blob/master/docs/api.md
class BlockBookUTXOProvider {
    static var rpcRequestId: Int = 0

    var host: String {
        "\(blockchain.currencySymbol.lowercased()).\(config.host)"
    }

    private let blockchain: Blockchain
    private let config: BlockBookConfig
    private let provider: NetworkProvider<BlockBookTarget>

    var decimalValue: Decimal {
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

    func rpcCall<Response: Decodable>(
        method: String,
        params: AnyEncodable,
        responseType: Response.Type
    ) -> AnyPublisher<JSONRPC.Response<Response, JSONRPC.APIError>, Error> {
        BlockBookUTXOProvider.rpcRequestId += 1
        let request = JSONRPC.Request(id: BlockBookUTXOProvider.rpcRequestId, method: method, params: params)
        return executeRequest(.rpc(request), responseType: JSONRPC.Response<Response, JSONRPC.APIError>.self)
    }

    func getFeeRatePerByte(for confirmationBlocks: Int) -> AnyPublisher<Decimal, Error> {
        switch blockchain {
        case .clore:
            executeRequest(
                .getFees(confirmationBlocks: confirmationBlocks),
                responseType: BlockBookFeeResultResponse.self
            )
            .withWeakCaptureOf(self)
            .tryMap { provider, response in
                guard let decimalFeeResult = Decimal(stringValue: response.result) else {
                    throw WalletError.failedToGetFee
                }

                return try provider.convertFeeRate(decimalFeeResult)
            }
            .eraseToAnyPublisher()
        default:
            rpcCall(
                method: "estimatesmartfee",
                params: AnyEncodable([confirmationBlocks]),
                responseType: BlockBookFeeRateResponse.Result.self
            )
            .withWeakCaptureOf(self)
            .tryMap { provider, response -> Decimal in
                try provider.convertFeeRate(response.result.get().feerate)
            }
            .eraseToAnyPublisher()
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
}

// MARK: - Private

extension BlockBookUTXOProvider {
    func executeRequest<T: Decodable>(_ request: BlockBookTarget.Request, responseType: T.Type) -> AnyPublisher<T, Error> {
        provider
            .requestPublisher(target(for: request))
            .filterSuccessfulStatusAndRedirectCodes()
            .map(responseType.self)
            .eraseError()
            .eraseToAnyPublisher()
    }

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
