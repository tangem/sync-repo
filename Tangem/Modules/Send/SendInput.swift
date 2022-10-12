//
//  SendInput.swift
//  Tangem
//
//  Created by Sergey Balashov on 11.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import struct BlockchainSdk.Amount
import struct BlockchainSdk.Transaction

protocol SendMaintainer {

}

struct SendInput {
    let amount: Amount
    let walletModel: WalletModel
    let config: UserWalletConfig
    let sendMaintainer: SendMaintainer
    let sdkErrorLogger: SDKErrorLogger
}

