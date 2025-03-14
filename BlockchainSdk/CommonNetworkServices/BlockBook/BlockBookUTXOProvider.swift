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
import TangemNetworkUtils

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

    func addressData(
        address: String,
        parameters: BlockBookTarget.AddressRequestParameters
    ) -> AnyPublisher<BlockBookAddressResponse, Error> {
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

// MARK: - UTXONetworkProvider

extension BlockBookUTXOProvider: UTXONetworkProvider {
    /// https://docs.syscoin.org/docs/dev-resources/documentation/javascript-sdk-ref/blockbook/#get-utxo
    func getUnspentOutputs(address: String) -> AnyPublisher<[UnspentOutput], any Error> {
        executeRequest(.utxo(address: address), responseType: [BlockBookUnspentTxResponse].self)
            .withWeakCaptureOf(self)
            .map { $0.mapToUnspentOutput(outputs: $1) }
            .eraseToAnyPublisher()
    }

    func getTransactionInfo(hash: String, address: String) -> AnyPublisher<TransactionRecord, any Error> {
        executeRequest(.txDetails(txHash: hash), responseType: BlockBookAddressResponse.Transaction.self)
            .withWeakCaptureOf(self)
            .tryMap { try $0.mapToTransactionRecord(transaction: $1, address: address) }
            .eraseToAnyPublisher()
    }

    func getFee() -> AnyPublisher<UTXOFee, any Error> {
        // Number of blocks we want the transaction to be confirmed in.
        // The lower the number the bigger the fee returned by 'estimatesmartfee'.
        let confirmationBlocks = [8, 4, 1]

        return mapBitcoinFee(confirmationBlocks.map { getFeeRatePerByte(for: $0) }).map {
            UTXOFee(
                slowSatoshiPerByte: $0.minimalSatoshiPerByte,
                marketSatoshiPerByte: $0.normalSatoshiPerByte,
                prioritySatoshiPerByte: $0.prioritySatoshiPerByte
            )
        }
        .eraseToAnyPublisher()
    }

    func send(transaction: String) -> AnyPublisher<TransactionSendResult, any Error> {
        guard let transactionData = transaction.data(using: .utf8) else {
            return .anyFail(error: WalletError.failedToSendTx)
        }

        return executeRequest(.sendBlockBook(tx: transactionData), responseType: SendResponse.self)
            .map { TransactionSendResult(hash: $0.result) }
            .eraseToAnyPublisher()
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
    func mapToUnspentOutput(outputs: [BlockBookUnspentTxResponse]) -> [UnspentOutput] {
        outputs.compactMap { output in
            Decimal(stringValue: output.value).map { value in
                .init(blockId: output.height ?? 0, hash: output.txid, index: output.vout, amount: value.uint64Value)
            }
        }
    }

    func mapToTransactionRecord(transaction: BlockBookAddressResponse.Transaction, address: String) throws -> TransactionRecord {
        try BlockBookTransactionTransactionRecordMapper(blockchain: blockchain)
            .mapToTransactionRecord(transaction: transaction, address: address)
    }
}
