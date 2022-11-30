//
//  TransactionBuilder.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 28.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol TransactionBuilder {
    associatedtype Transaction

    func buildTransaction(for info: ExchangeTransactionInfo, fee: Decimal) throws -> Transaction
    func sign(_ transaction: Transaction) async throws -> Transaction
    func send(_ transaction: Transaction) async throws
}
