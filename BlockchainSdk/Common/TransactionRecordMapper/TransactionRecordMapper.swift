//
//  TransactionRecordMapper.swift
//  TangemApp
//
//  Created by Sergey Balashov on 26.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

// Will be supported in BTC-like / Fact0rn / Radiant and etc.
protocol TransactionRecordMapper {
    associatedtype Transaction
    func mapToTransactionRecord(transaction: Transaction) throws -> TransactionRecord
}
