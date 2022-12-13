//
//  UserCurrenciesProviderMock.swift
//  Tangem
//
//  Created by Sergey Balashov on 06.12.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemExchange

struct UserCurrenciesProviderMock: UserCurrenciesProviding {
    func getCurrencies(blockchain: ExchangeBlockchain) -> [Currency] { [.mock] }
    func add(currency: Currency) {}
}
