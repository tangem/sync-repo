//
//  BlockchainInfoProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 15.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

public protocol BlockchainInfoProvider {
    func getBalance(currency: Currency) async throws -> Decimal
    func getFee(currency: Currency, amount: Decimal, destination: String) async throws -> [Decimal]
}
