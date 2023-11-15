//
//  SendType.swift
//  Tangem
//
//  Created by Andrey Chukavin on 10.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

enum SendType {
    case send
    case sell(amount: Decimal, destination: String)
}

extension SendType {
    var steps: [SendStep] {
        switch self {
        case .send:
            return [.amount, .destination, .fee, .summary]
        case .sell:
            return [.summary]
        }
    }

    var predefinedAmount: Decimal? {
        switch self {
        case .send:
            return nil
        case .sell(let amount, _):
            return amount
        }
    }

    var predefinedDestination: String? {
        switch self {
        case .send:
            return nil
        case .sell(_, let destination):
            return destination
        }
    }
}
