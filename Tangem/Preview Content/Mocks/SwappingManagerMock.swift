//
//  SwappingManagerMock.swift
//  Tangem
//
//  Created by Sergey Balashov on 06.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSwapping

struct SwappingManagerMock: SwappingManager {
    func getAmount() -> Decimal? { 0.1 }

    func refreshBalances() async -> SwappingItems { getSwappingItems() }
    func refresh(type: TangemSwapping.SwappingManagerRefreshType) async -> TangemSwapping.SwappingAvailabilityState { .idle }

    func getSwappingItems() -> TangemSwapping.SwappingItems {
        SwappingItems(source: .mock, destination: .mock)
    }

    func getReferrerAccount() -> SwappingReferrerAccount? { nil }

    func update(swappingItems: SwappingItems) {}

    func update(amount: Decimal?) {}

    func isEnoughAllowance() -> Bool { true }

    func didSendApprovingTransaction(swappingTxData: SwappingTransactionData) {}
}
