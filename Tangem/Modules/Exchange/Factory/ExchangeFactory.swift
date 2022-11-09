//
//  ExchangeFactory.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 08.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

class ExchangeFacadeFactory {
    enum Router {
        case oneInch
    }

    func createFacade(for router: Router, exchangeManager: ExchangeManager, signer: TangemSigner) -> ExchangeFacade {
        switch router {
        case .oneInch:
            return ExchangeOneInchFacade(exchangeManager: exchangeManager, signer: signer)
        }
    }
}
