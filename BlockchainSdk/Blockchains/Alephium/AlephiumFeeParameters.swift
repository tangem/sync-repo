//
//  AlephiumFeeParameters.swift
//  BlockchainSdk
//
//  Created by Alexander Skibin on 03.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct AlephiumFeeParameters: FeeParameters {
    let gasPrice: Decimal
    let gasAmount: Int
}
