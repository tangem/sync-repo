//
//  RadiantAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/4/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import BitcoinCore
import CryptoKit
@testable import BlockchainSdk
import Testing

struct RadiantAddressTests {
    /// Validate by https://github.com/RadiantBlockchain/radiantjs
    @Test
    func addressGeneration() throws {
        let addressServiceFactory = AddressServiceFactory(blockchain: .radiant(testnet: false))
        let addressService = addressServiceFactory.makeAddressService()

        let addr1 = try addressService.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)
        #expect(addr1.value == "1JjXGY5KEcbT35uAo6P9A7DebBn4DXnjdQ")

        let addr2 = try addressService.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        #expect(addr2.value == "1JjXGY5KEcbT35uAo6P9A7DebBn4DXnjdQ")

        let anyOnePublicKey = Data(hexString: "039d645d2ce630c2a9a6dbe0cbd0a8fcb7b70241cb8a48424f25593290af2494b9")
        let addr3 = try addressService.makeAddress(from: anyOnePublicKey)

        #expect(addr3.value == "12dNaXQtN5Asn2YFwT1cvciCrJa525fAe4")

        let anyTwoPublicKey = Data(hexString: "03d6fde463a4d0f4decc6ab11be24e83c55a15f68fd5db561eebca021976215ff5")
        let addr4 = try addressService.makeAddress(from: anyTwoPublicKey)

        #expect(addr4.value == "166w5AGDyvMkJqfDAtLbTJeoQh6FqYCfLQ")

        // For ed25519 wrong make address from public key
        let edPublicKey = Data(hex: "e7287a82bdcd3a5c2d0ee2150ccbc80d6a00991411fb44cd4d13cef46618aadb")
        #expect(throws: (any Error).self) {
            try addressService.makeAddress(from: edPublicKey)
        }
    }

    /// https://github.com/RadiantBlockchain/radiantjs/blob/master/test/address.js
    @Test
    func addressValidation() throws {
        let addressServiceFactory = AddressServiceFactory(blockchain: .radiant(testnet: false))
        let addressService = addressServiceFactory.makeAddressService()

        #expect(addressService.validate("15vkcKf7gB23wLAnZLmbVuMiiVDc1Nm4a2"))
        #expect(addressService.validate("1A6ut1tWnUq1SEQLMr4ttDh24wcbJ5o9TT"))
        #expect(addressService.validate("1BpbpfLdY7oBS9gK7aDXgvMgr1DPvNhEB2"))
        #expect(addressService.validate("1Jz2yCRd5ST1p2gUqFB5wsSQfdm3jaFfg7"))
        #expect(addressService.validate("166w5AGDyvMkJqfDAtLbTJeoQh6FqYCfLQ"))
        #expect(addressService.validate("12dNaXQtN5Asn2YFwT1cvciCrJa525fAe4"))
        #expect(addressService.validate("1JjXGY5KEcbT35uAo6P9A7DebBn4DXnjdQ"))

        #expect(!addressService.validate("342ftSRCvFHfCeFFBuz4xwbeqnDw6BGUey"))
        #expect(!addressService.validate("3QjYXhTkvuj8qPaXHTTWb5wjXhdsLAAWVy"))
        #expect(!addressService.validate("15vkcKf7gB23wLAnZLmbVuMiiVDc3nq4a2"))
        #expect(!addressService.validate("1A6ut1tWnUq1SEQLMr4ttDh24wcbj4w2TT"))
        #expect(!addressService.validate("1Jz2yCRd5ST1p2gUqFB5wsSQfdmEJaffg7"))
        #expect(!addressService.validate("1BpbpfLdY7oBS9gK7aDXgvMgr1DpvNH3B2"))
    }
}
