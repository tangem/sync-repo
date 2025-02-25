//
//  VisaCustomerCardInfo.swift
//  TangemVisa
//
//  Created by Andrew Son on 19/02/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

public struct VisaCustomerCardInfo {
    public let paymentAccount: String
    public let cardId: String
    public let cardWalletAddress: String
    public let customerInfo: VisaCustomerInfoResponse?
}

public enum VisaPaymentAccountAddressProviderError: LocalizedError {
    case bffIsNotAvailable
    case missingProductInstanceForCardId
    case missingPaymentAccountForCard
}
