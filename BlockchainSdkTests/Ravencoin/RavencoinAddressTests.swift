//
//  RavencoinAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/5/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing
import enum WalletCore.CoinType

struct RavencoinAddressTests {
    @Test
    func address() throws {
        let addressService = BitcoinLegacyAddressService(networkParams: RavencoinMainNetworkParams())

        let compAddress = try addressService.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)
        let expectedCompAddress = "RT1iM3xbqSQ276GNGGNGFdYrMTEeq4hXRH"
        #expect(compAddress.value == expectedCompAddress)

        let decompAddress = try addressService.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        let expectedDecompAddress = "RRjP4a6i7e1oX1mZq1rdQpNMHEyDdSQVNi"
        #expect(decompAddress.value == expectedDecompAddress)

        #expect(addressService.validate(compAddress.value))
        #expect(addressService.validate(decompAddress.value))

        #expect(throws: (any Error).self) {
            try addressService.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test(arguments: [
        "RT1iM3xbqSQ276GNGGNGFdYrMTEeq4hXRH",
        "RRjP4a6i7e1oX1mZq1rdQpNMHEyDdSQVNi",
    ])
    func validAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator = WalletCoreAddressService(coin: .ravencoin, publicKeyType: CoinType.ravencoin.publicKeyType)
        let addressValidator = AddressServiceFactory(blockchain: .ravencoin(testnet: false)).makeAddressService()

        #expect(walletCoreAddressValidator.validate(addressHex))
        #expect(addressValidator.validate(addressHex))
    }

    @Test(arguments: [
        "QT1iM3xbqSQ276GNGGNGFdYrMTEeq4hXRH",
    ])
    func invalidAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator
        walletCoreAddressValidator = WalletCoreAddressService(coin: .ravencoin, publicKeyType: CoinType.ravencoin.publicKeyType)
        let addressValidator = AddressServiceFactory(blockchain: .ravencoin(testnet: false)).makeAddressService()

        #expect(!walletCoreAddressValidator.validate(addressHex))
        #expect(!addressValidator.validate(addressHex))
    }
}
