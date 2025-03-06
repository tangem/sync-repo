//
//  DashAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/5/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing

struct DashAddressTests {
    private let addressesUtility = AddressServiceManagerUtility()

    @Test
    func addressGeneration() throws {
        let blockchain = Blockchain.dash(testnet: false)
        let addressService = BitcoinLegacyAddressService(networkParams: DashMainNetworkParams())

        let compressedExpectedAddress = "XtRN6njDCKp3C2VkeyhN1duSRXMkHPGLgH"
        let decompressedExpectedAddress = "Xs92pJsKUXRpbwzxDjBjApiwMK6JysNntG"

        // when
        let compressedKeyAddress = try addressService.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)
        let decompressedKeyAddress = try addressService.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)

        // then
        #expect(compressedKeyAddress.value == compressedExpectedAddress)
        #expect(decompressedKeyAddress.value == decompressedExpectedAddress)

        let addressUtility = try addressesUtility.makeTrustWalletAddress(publicKey: Keys.AddressesKeys.secpCompressedKey, for: blockchain)
        #expect(addressUtility == compressedKeyAddress.value)

        #expect(throws: (any Error).self) {
            try addressService.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test
    func addressValidation() throws {
        let addressService = BitcoinLegacyAddressService(networkParams: DashMainNetworkParams())

        #expect(addressService.validate("XwrhJMJKUpP21KShxqv6YcaTQZfiZXdREQ"))
        #expect(addressService.validate("XdDGLNAAXF91Da58hYwHqQmFEWPGTh3L8p"))
        #expect(addressService.validate("XuRzigQHyJfvw35e281h5HPBqJ8HZjF8M4"))

        #expect(!addressService.validate("RJRyWwFs9wTFGZg3JbrVriFbNfCug5tDeC"))
        #expect(!addressService.validate("XuRzigQHyJfvw35e281h5HPBqJ8"))
        #expect(!addressService.validate(""))
    }
}
