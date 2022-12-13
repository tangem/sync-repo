//
//  TransactionSender.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 12.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol TransactionSenderProtocol {
    func sendExchangeTransaction(_ info: ExchangeTransactionInfo, gasValue: Decimal, gasPrice: Decimal) async throws
    func sendPermissionTransaction(_ info: ExchangeTransactionInfo, gasPrice: Decimal) async throws
}
