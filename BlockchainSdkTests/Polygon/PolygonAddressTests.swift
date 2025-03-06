//
//  PolygonAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/6/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing
import WalletCore

struct PolygonAddressTests {
    @Test(arguments: [
        "0x6ECa00c52AFC728CDbF42E817d712e175bb23C7d",
    ])
    func validAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator = WalletCoreAddressService(coin: .polygon, publicKeyType: CoinType.polygon.publicKeyType)
        let addressValidator = AddressServiceFactory(blockchain: .polygon(testnet: false)).makeAddressService()

        #expect(walletCoreAddressValidator.validate(addressHex))
        #expect(addressValidator.validate(addressHex))
    }
}
