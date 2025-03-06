//
//  JoystreamAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/5/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing

struct JoystreamAddressTests {
    @Test
    func joystream() {
        testSubstrateNetwork(
            .joystream(curve: .ed25519),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "j4UwGHUYcR4HH6qiZ4WJJPBKsYboMJWe6WPj8V6uKfo4Gnhbt"
        )

        testSubstrateNetwork(
            .joystream(curve: .ed25519_slip0010),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "j4UwGHUYcR4HH6qiZ4WJJPBKsYboMJWe6WPj8V6uKfo4Gnhbt"
        )
    }

    @Test
    func bittensor() throws {
        testSubstrateNetwork(
            .bittensor(curve: .ed25519),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "5FgMiSJeYLnFGEGonXrcY2ct2Dimod4vnT6h7Ys1Eiue9KxK"
        )

        testSubstrateNetwork(
            .bittensor(curve: .ed25519_slip0010),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "5FgMiSJeYLnFGEGonXrcY2ct2Dimod4vnT6h7Ys1Eiue9KxK"
        )
    }

    private func testSubstrateNetwork(_ blockchain: Blockchain, publicKey: Data, expectedAddress: String) {
        let network = PolkadotNetwork(blockchain: blockchain)!
        let service = PolkadotAddressService(network: network)

        let address = try! service.makeAddress(from: publicKey)
        let addressFromString = PolkadotAddress(string: expectedAddress, network: network)

        guard let addressFromString else {
            #expect(Bool(false))
            return
        }
        #expect(addressFromString.bytes(raw: true) == publicKey)
        #expect(address.value == expectedAddress)
        #expect(addressFromString.bytes(raw: false) != publicKey)

        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)
        }
        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        }
    }
}
