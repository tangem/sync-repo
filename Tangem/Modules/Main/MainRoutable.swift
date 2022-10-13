//
//  MainRoutable.swift
//  Tangem
//
//  Created by Alexander Osokin on 15.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

protocol MainRoutable: TokenDetailsRoutable {
    func close(newScan: Bool)
    func openSettings(input: DetailsInput)
    func openTokenDetails(input: TokenDetailsInput)
    func openOnboardingModal(with input: OnboardingInput)
    func openCurrencySelection(autoDismiss: Bool)
    func openTokensList(with input: TokenListInput)
    func openMail(with dataCollector: EmailDataCollector, emailType: EmailType, recipient: String)
    func openQR(shareAddress: String, address: String, qrNotice: String)
}
