//
//  KaspaTransactionHistoryProvider.swift
//  BlockchainSdk
//
//  Created by Dmitry Fedorov on 04.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import TangemNetworkUtils

final class KaspaTransactionHistoryProvider: TransactionHistoryProvider {
    private let networkProvider: NetworkProvider<KaspaTransactionHistoryTarget>
    private let mapper: KaspaTransactionHistoryMapper

    private var page: TransactionHistoryIndexPage?
    private var hasReachedEnd = false

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    init(
        networkConfiguration: NetworkProviderConfiguration,
        mapper: KaspaTransactionHistoryMapper
    ) {
        networkProvider = .init(configuration: networkConfiguration)
        self.mapper = mapper
    }

    var canFetchHistory: Bool {
        hasReachedEnd == false
    }

    func loadTransactionHistory(request: TransactionHistory.Request) -> AnyPublisher<TransactionHistory.Response, any Error> {
        let requestPage: Int
        // if indexing is created, load the next page
        if let page {
            requestPage = page.number + 1
        } else {
            requestPage = 0
        }

        let target = KaspaTransactionHistoryTarget(
            type: .getCoinTransactionHistory(
                address: request.address,
                page: requestPage,
                limit: request.limit
            )
        )
        return networkProvider.requestPublisher(target)
            .filterSuccessfulStatusAndRedirectCodes()
            .map(KaspaTransactionHistoryResponse.self, using: decoder)
            .eraseError()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.page = TransactionHistoryIndexPage(number: requestPage)
            })
            .withWeakCaptureOf(self)
            .tryMap { historyProvider, result in
                let transactionRecords = try historyProvider
                    .mapper
                    .mapToTransactionRecords(result, walletAddress: request.address, amountType: request.amountType)
                    .filter { record in
                        historyProvider.shouldBeIncludedInHistory(
                            amountType: request.amountType,
                            record: record
                        )
                    }
                return TransactionHistory.Response(records: transactionRecords)
            }
            .eraseToAnyPublisher()
    }

    func reset() {
        page = nil
    }
}
