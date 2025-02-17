//
//  ALPH+TxInputData.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 03.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

extension ALPH {
    struct TxInputInfo {
        let outputRef: AssetOutputRef
        let unlockScript: UnlockScript
    }
}
