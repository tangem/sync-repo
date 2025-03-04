//
//  PendingExpressTransactionParams.swift
//  Tangem
//
//  Created by Alexander Skibin on 04.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemExpress

struct PendingExpressTransactionParams {
    let externalStatus: ExpressTransactionStatus
    let averageDuration: TimeInterval?
    let createdAt: Date?
}
