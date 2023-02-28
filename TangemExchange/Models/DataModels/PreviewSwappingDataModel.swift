//
//  PreviewSwappingDataModel.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 12.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public struct PreviewSwappingDataModel {
    public let paymentAmount: Decimal
    public let expectedAmount: Decimal
    public let isPermissionRequired: Bool
    public let hasPendingTransaction: Bool
    public let isEnoughAmountForExchange: Bool

    public init(
        paymentAmount: Decimal,
        expectedAmount: Decimal,
        isPermissionRequired: Bool,
        hasPendingTransaction: Bool,
        isEnoughAmountForExchange: Bool
    ) {
        self.paymentAmount = paymentAmount
        self.expectedAmount = expectedAmount
        self.isPermissionRequired = isPermissionRequired
        self.hasPendingTransaction = hasPendingTransaction
        self.isEnoughAmountForExchange = isEnoughAmountForExchange
    }
}
