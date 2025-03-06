//
//  DogecoinAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/5/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing

struct DogecoinAddressTests {
    private let addressesUtility = AddressServiceManagerUtility()

    @Test
    func addressGeneration() throws {
        let blockchain = Blockchain.dogecoin
        let service = BitcoinLegacyAddressService(networkParams: DogecoinNetworkParams())

        let addr_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        let addr_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)

        #expect(addr_dec.value == "DMbHXKA4pE7Wz1ay6Rs4s4CkQ7EvKG3DqY")
        #expect(addr_dec.localizedName == addr_comp.localizedName)
        #expect(addr_dec.type == addr_comp.type)
        #expect(addr_comp.value == "DNscoo1xY2Vja65mXgNhhsPFUKWMa7NLEb")

        try #expect(addressesUtility.makeTrustWalletAddress(publicKey: Keys.AddressesKeys.secpDecompressedKey, for: blockchain) == addr_comp.value)

        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test
    func addressValidation() throws {
        let addressService = BitcoinLegacyAddressService(networkParams: DogecoinNetworkParams())

        #expect(addressService.validate("DDWSSN4qy1ccJ1CYgaB6HGs4Euknqb476q"))
        #expect(addressService.validate("D6H6nVsCmsodv7SLQd1KpfsmkUKmhXhP3g"))
        #expect(addressService.validate("DCGx73ispbchmXfNczfp9TtWfKtzgzgp8N"))

        #expect(!addressService.validate("DCGx73ispbchmXfNczfp9TtWfKtzgzgp"))
        #expect(!addressService.validate("CCGx73ispbchmXfNczfp9TtWfKtzgzgp8N"))
        #expect(!addressService.validate(""))
    }
}
