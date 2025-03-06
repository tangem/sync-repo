//
//  PolkdotAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/4/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import BitcoinCore
import CryptoKit
import TangemSdk
@testable import BlockchainSdk
import Testing
import enum WalletCore.CoinType

struct PolkadotAddressTests {
    private let curves = [EllipticCurve.ed25519, .ed25519_slip0010]

    @Test
    func polkadot() throws {
        // From trust wallet `PolkadotTests.swift`
        let privateKey = Data(hexString: "0xd65ed4c1a742699b2e20c0c1f1fe780878b1b9f7d387f934fe0a7dc36f1f9008")
        let publicKey = try! Curve25519.Signing.PrivateKey(rawRepresentation: privateKey).publicKey.rawRepresentation

        testSubstrateNetwork(
            .polkadot(curve: .ed25519, testnet: false),
            publicKey: publicKey,
            expectedAddress: "12twBQPiG5yVSf3jQSBkTAKBKqCShQ5fm33KQhH3Hf6VDoKW"
        )

        testSubstrateNetwork(
            .polkadot(curve: .ed25519_slip0010, testnet: false),
            publicKey: publicKey,
            expectedAddress: "12twBQPiG5yVSf3jQSBkTAKBKqCShQ5fm33KQhH3Hf6VDoKW"
        )

        testSubstrateNetwork(
            .polkadot(curve: .ed25519, testnet: false),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "14cermZiQ83ihmHKkAucgBT2sqiRVvd4rwqBGqrMnowAKYRp"
        )

        testSubstrateNetwork(
            .polkadot(curve: .ed25519_slip0010, testnet: false),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "14cermZiQ83ihmHKkAucgBT2sqiRVvd4rwqBGqrMnowAKYRp"
        )
    }

    @Test
    func kusama() throws {
        // From trust wallet `KusamaTests.swift`
        let privateKey = Data(hexString: "0x85fca134b3fe3fd523d8b528608d803890e26c93c86dc3d97b8d59c7b3540c97")
        let publicKey = try Curve25519.Signing.PrivateKey(rawRepresentation: privateKey).publicKey.rawRepresentation
        testSubstrateNetwork(
            .kusama(curve: .ed25519),
            publicKey: publicKey,
            expectedAddress: "HewiDTQv92L2bVtkziZC8ASxrFUxr6ajQ62RXAnwQ8FDVmg"
        )

        testSubstrateNetwork(
            .kusama(curve: .ed25519_slip0010),
            publicKey: publicKey,
            expectedAddress: "HewiDTQv92L2bVtkziZC8ASxrFUxr6ajQ62RXAnwQ8FDVmg"
        )

        testSubstrateNetwork(
            .kusama(curve: .ed25519),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "GByNkeXAhoB1t6FZEffRyytAp11cHt7EpwSWD8xiX88tLdQ"
        )

        testSubstrateNetwork(
            .kusama(curve: .ed25519_slip0010),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "GByNkeXAhoB1t6FZEffRyytAp11cHt7EpwSWD8xiX88tLdQ"
        )
    }

    @Test
    func westend() {
        testSubstrateNetwork(
            .polkadot(curve: .ed25519, testnet: true),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "5FgMiSJeYLnFGEGonXrcY2ct2Dimod4vnT6h7Ys1Eiue9KxK"
        )

        testSubstrateNetwork(
            .polkadot(curve: .ed25519_slip0010, testnet: true),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "5FgMiSJeYLnFGEGonXrcY2ct2Dimod4vnT6h7Ys1Eiue9KxK"
        )
    }

    @Test
    func azero() {
        testSubstrateNetwork(
            .azero(curve: .ed25519, testnet: true),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "5FgMiSJeYLnFGEGonXrcY2ct2Dimod4vnT6h7Ys1Eiue9KxK"
        )

        testSubstrateNetwork(
            .azero(curve: .ed25519_slip0010, testnet: true),
            publicKey: Keys.AddressesKeys.edKey,
            expectedAddress: "5FgMiSJeYLnFGEGonXrcY2ct2Dimod4vnT6h7Ys1Eiue9KxK"
        )
    }

    @Test(arguments: [
        "12twBQPiG5yVSf3jQSBkTAKBKqCShQ5fm33KQhH3Hf6VDoKW",
        "14PhJGbzPxhQbiq7k9uFjDQx3MNiYxnjFRSiVBvBBBfnkAoM",
    ])
    func validAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator = WalletCoreAddressService(coin: .polkadot, publicKeyType: CoinType.polkadot.publicKeyType)

        curves.forEach {
            let addressValidator = AddressServiceFactory(blockchain: .polkadot(curve: $0, testnet: false)).makeAddressService()

            #expect(walletCoreAddressValidator.validate(addressHex))
            #expect(addressValidator.validate(addressHex))
        }
    }

    @Test(arguments: [
        "cosmos1l4f4max9w06gqrvsxf74hhyzuqhu2l3zyf0480",
        "3317oFJC9FvxU2fwrKVsvgnMGCDzTZ5nyf",
        "ELmaX1aPkyEF7TSmYbbyCjmSgrBpGHv9EtpwR2tk1kmpwvG",
    ])
    func invalidAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator = WalletCoreAddressService(coin: .polkadot, publicKeyType: CoinType.polkadot.publicKeyType)

        curves.forEach {
            let addressValidator = AddressServiceFactory(blockchain: .polkadot(curve: $0, testnet: false)).makeAddressService()

            #expect(!walletCoreAddressValidator.validate(addressHex))
            #expect(!addressValidator.validate(addressHex))
        }
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
