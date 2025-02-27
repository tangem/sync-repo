//
//  AlephiumUtils.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 17.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct AlephiumUtils {
    func isNotFromFuture(lockTime: Double) -> Bool {
        let nowMillis = Date().timeIntervalSince1970 * 1000
        return lockTime <= nowMillis
    }
}
