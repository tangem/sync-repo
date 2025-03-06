//
//  LitecoinAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/4/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import BitcoinCore
@testable import BlockchainSdk
import Testing

struct LitecoinAddressTests {
    private let addressesUtility = AddressServiceManagerUtility()

    @Test
    func addressGeneration() throws {
        let blockchain = Blockchain.litecoin
        let service = BitcoinAddressService(networkParams: LitecoinNetworkParams())

        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.edKey)
        }

        let bech32_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey, type: .default)
        let bech32_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey, type: .default)

        #expect(bech32_dec.value == bech32_comp.value)
        #expect(bech32_dec.value == "ltc1qc2zwqqucrqvvtyxfn78ajm8w2sgyjf5efy0t9t") // TODO: validate
        #expect(bech32_dec.localizedName == bech32_comp.localizedName)

        try #expect(addressesUtility.makeTrustWalletAddress(publicKey: Keys.AddressesKeys.secpDecompressedKey, for: blockchain) == bech32_dec.value)

        let leg_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey, type: .legacy)
        let leg_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey, type: .legacy)
        #expect(leg_dec.localizedName == leg_comp.localizedName)
        #expect(leg_dec.value == "Lbg9FGXFbUTHhp6XXyrobK6ujBsu7UE7ww")
        #expect(leg_comp.value == "LcxUXkP9KGqWHtbKyENSS8HQoQ9LK8DQLX")
    }

    @Test
    func addressValidation() throws {
        let addressService = BitcoinAddressService(networkParams: LitecoinNetworkParams())

        #expect(addressService.validate("LMbRCidgQLz1kNA77gnUpLuiv2UL6Bc4Q2"))
        #expect(addressService.validate("ltc1q5wmm9vrz55war9c0rgw26tv9un5fxnn7slyjpy"))
        #expect(addressService.validate("MPmoY6RX3Y3HFjGEnFxyuLPCQdjvHwMEny"))
        #expect(addressService.validate("LWjJD6H1QrMmCQ5QhBKMqvPqMzwYpJPv2M"))

        #expect(!addressService.validate("1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2"))
    }
}
