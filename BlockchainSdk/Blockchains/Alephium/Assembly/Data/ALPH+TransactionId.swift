//
//  ALPH+TransactionId.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 03.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

extension ALPH {
    struct TransactionId {
        let value: ALPH.Blake2b

        var bytes: Data {
            Data(value.bytes)
        }

        static func hash(bytes: Data) -> TransactionId {
            TransactionId(value: ALPH.Blake2b.hash(bytes))
        }
    }
}
