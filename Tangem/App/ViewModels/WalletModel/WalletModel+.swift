//
//  WalletModel+.swift
//  Tangem
//
//  Created by Andrew Son on 04/09/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import TangemFoundation

extension WalletModel {
    static func == (lhs: any WalletModel, rhs: any WalletModel) -> Bool {
        return lhs.id == rhs.id
    }
}

extension WalletModel {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - CustomStringConvertible protocol conformance

extension WalletModel {
    var description: String {
        TangemFoundation.objectDescription(
            self,
            userInfo: [
                "name": name,
                "isMainToken": isMainToken,
                "tokenItem": "\(tokenItem.name) (\(tokenItem.networkName))",
            ]
        )
    }
}
