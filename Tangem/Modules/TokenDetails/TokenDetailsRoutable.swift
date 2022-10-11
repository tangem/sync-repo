//
//  TokenDetailsRoutable.swift
//  Tangem
//
//  Created by Alexander Osokin on 17.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

protocol TokenDetailsRoutable: AnyObject {
    func openBuyCrypto(at url: URL, closeUrl: String, action: @escaping (String) -> Void)
    func openSellCrypto(at url: URL, sellRequestUrl: String, action: @escaping (String) -> Void)
    func openExplorer(at url: URL, blockchainDisplayName: String)
    func openSend(input: SendInput)
    func openSendToSell(input: SendInput, destination: String)
    func openPushTx(input: PushTxInput)
    func openBankWarning(confirmCallback: @escaping () -> (), declineCallback: @escaping () -> ())
    func openP2PTutorial()
    func dismiss()
}
