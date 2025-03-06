//
//  StakeKitTransactionStatusProvider.swift
//  TangemApp
//
//  Created by Dmitry Fedorov on 14.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

public protocol StakeKitTransactionStatusProvider {
    func transactionStatus(_ transaction: StakeKitTransaction) async throws -> StakeKitTransaction.Status?
}
