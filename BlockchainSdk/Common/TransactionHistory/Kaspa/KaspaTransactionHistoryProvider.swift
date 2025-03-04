//
//  KaspaTransactionHistoryProvider.swift
//  BlockchainSdk
//
//  Created by Dmitry Fedorov on 04.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

final class KaspaTransactionHistoryProvider: TransactionHistoryProvider {
    var canFetchHistory: Bool
    
    func loadTransactionHistory(request: TransactionHistory.Request) -> AnyPublisher<TransactionHistory.Response, any Error> {
        <#code#>
    }
    
    func reset() {
        <#code#>
    }
    
    
}
