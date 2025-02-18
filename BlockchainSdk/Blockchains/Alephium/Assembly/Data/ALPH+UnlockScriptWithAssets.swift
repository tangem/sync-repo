//
//  ALPH+UnlockScriptWithAssets.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 03.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension ALPH {
    struct UnlockScriptWithAssets {
        let fromUnlockScript: UnlockScript
        let assets: [(AssetOutputRef, AssetOutput)]
    }
}
