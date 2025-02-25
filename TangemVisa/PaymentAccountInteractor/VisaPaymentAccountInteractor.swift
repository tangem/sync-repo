//
//  VisaPaymentAccountInteractor.swift
//  TangemVisa
//
//  Created by Andrew Son on 15/01/24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk

public protocol VisaPaymentAccountInteractor {
    var visaToken: Token { get }
    var accountAddress: String { get }
    var cardWalletAddress: String { get }
    func loadBalances() async throws -> VisaBalances
    func loadCardSettings() async throws -> VisaPaymentAccountCardSettings
}
