//
//  VisaParserError.swift
//  TangemVisa
//
//  Created by Andrew Son on 19/01/24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

public enum VisaParserError: String, LocalizedError {
    case addressResponseDoesntContainAddress
    case addressesResponseHasWrongLength
    case noValidAddress
    case limitsResponseWrongLength
    case limitWrongLength
    case limitWrongSingleLimitItemsCount
    case limitWrongSingleLimitAmountsCount
    case notEnoughOTPData

    public var errorDescription: String? {
        rawValue
    }
}
