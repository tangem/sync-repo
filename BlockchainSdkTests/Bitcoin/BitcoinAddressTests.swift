//
//  BitcoinAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/3/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import CryptoKit
import WalletCore
import BitcoinCore
@testable import BlockchainSdk
import Testing

struct BitcoinAddressTests {
    private let addressesUtility = AddressServiceManagerUtility()
    private let blockchain = Blockchain.bitcoin(testnet: false)

    @Test
    func address() throws {
        // given
        let blockchain = Blockchain.bitcoin(testnet: false)
        let service = BitcoinAddressService(networkParams: BitcoinNetwork.mainnet.networkParams)

        // when
        let bech32_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey, type: .default)
        let bech32_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey, type: .default)

        let leg_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey, type: .legacy)
        let leg_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey, type: .legacy)

        // then
        #expect(bech32_dec.value == bech32_comp.value)
        #expect(bech32_dec.value == "bc1qc2zwqqucrqvvtyxfn78ajm8w2sgyjf5edc40am")
        #expect(bech32_dec.localizedName == bech32_comp.localizedName)

        try #expect(
            addressesUtility.makeTrustWalletAddress(
                publicKey: Keys.AddressesKeys.secpDecompressedKey,
                for: blockchain
            ) == bech32_dec.value
        )

        #expect(leg_dec.localizedName == leg_comp.localizedName)
        #expect(leg_dec.value == "1HTBz4DRWpDET1QNMqsWKJ39WyWcwPWexK")
        #expect(leg_comp.value == "1JjXGY5KEcbT35uAo6P9A7DebBn4DXnjdQ")

        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test
    func testnet() throws {
        // given
        let service = BitcoinAddressService(networkParams: BitcoinNetwork.testnet.networkParams)

        // when
        let bech32_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey, type: .default)
        let bech32_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey, type: .default)

        let leg_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey, type: .legacy)
        let leg_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey, type: .legacy)

        // then
        #expect(bech32_dec.value == bech32_comp.value)
        #expect(bech32_dec.localizedName == bech32_comp.localizedName)
        #expect(bech32_dec.value == "tb1qc2zwqqucrqvvtyxfn78ajm8w2sgyjf5e87wuxg") // TODO: validate with android

        #expect(leg_dec.localizedName == leg_comp.localizedName)
        #expect(leg_dec.value == "mwy9H7JQKqeVE7sz5Qqt9DFUNy7KtX7wHj") // TODO: validate with android
        #expect(leg_comp.value == "myFUZbAJ3e2hpCNnWfMWz2RyTBNm7vdnSQ") // TODO: validate with android

        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test
    func btcTwin() throws {
        // given
        let secpPairDecompressedKey = Data(hexString: "042A5741873B88C383A7CFF4AA23792754B5D20248F1A24DF1DAC35641B3F97D8936D318D49FE06E3437E31568B338B340F4E6DF5184E1EC5840F2B7F4596902AE")
        let secpPairCompressedKey = Data(hexString: "022A5741873B88C383A7CFF4AA23792754B5D20248F1A24DF1DAC35641B3F97D89")
        let service = BitcoinAddressService(networkParams: BitcoinNetwork.mainnet.networkParams)

        // when
        let addr_dec = try service.makeAddresses(
            publicKey: .init(seedKey: Keys.AddressesKeys.secpDecompressedKey, derivationType: .none),
            pairPublicKey: secpPairDecompressedKey
        )
        let addr_dec1 = try service.makeAddresses(
            publicKey: .init(seedKey: Keys.AddressesKeys.secpDecompressedKey, derivationType: .none),
            pairPublicKey: secpPairCompressedKey
        )
        let addr_comp = try service.makeAddresses(
            publicKey: .init(seedKey: Keys.AddressesKeys.secpCompressedKey, derivationType: .none),
            pairPublicKey: secpPairCompressedKey
        )
        let addr_comp1 = try service.makeAddresses(
            publicKey: .init(seedKey: Keys.AddressesKeys.secpCompressedKey, derivationType: .none),
            pairPublicKey: secpPairDecompressedKey
        )

        // then
        #expect(addr_dec.count == 2)
        #expect(addr_dec1.count == 2)
        #expect(addr_comp.count == 2)
        #expect(addr_comp1.count == 2)

        #expect(addr_dec.first(where: { $0.type == .default })!.value == "bc1q0u3heda6uhq7fulsqmw40heuh3e76nd9skxngv93uzz3z6xtpjmsrh88wh")
        #expect(addr_dec.first(where: { $0.type == .legacy })!.value == "34DmpSKfsvqxgzVVhcEepeX3s67ai4ShPq")

        for index in 0 ..< 2 {
            #expect(addr_dec[index].value == addr_dec1[index].value)
            #expect(addr_dec[index].value == addr_comp[index].value)
            #expect(addr_dec[index].value == addr_comp1[index].value)

            #expect(addr_dec[index].localizedName == addr_dec1[index].localizedName)
            #expect(addr_dec[index].localizedName == addr_comp[index].localizedName)
            #expect(addr_dec[index].localizedName == addr_comp1[index].localizedName)

            #expect(addr_dec[index].type == addr_dec1[index].type)
            #expect(addr_dec[index].type == addr_comp[index].type)
            #expect(addr_dec[index].type == addr_comp1[index].type)
        }
    }

    @Test(arguments: [
        "bc1q2ddhp55sq2l4xnqhpdv0xazg02v9dr7uu8c2p2",
        "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
        "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
        "1AC4gh14wwZPULVPCdxUkgqbtPvC92PQPN",
        "1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs",
        "bc1qcj2vfjec3c3luf9fx9vddnglhh9gawmncmgxhz",
    ])
    func validAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator = WalletCoreAddressService(coin: .bitcoin, publicKeyType: CoinType.bitcoin.publicKeyType)
        let addressValidator = AddressServiceFactory(blockchain: blockchain).makeAddressService()

        #expect(walletCoreAddressValidator.validate(addressHex))
        #expect(addressValidator.validate(addressHex))
    }

    @Test(arguments: [
        "bc1q2ddhp55sq2l4xnqhpdv9xazg02v9dr7uu8c2p2",
        "MPmoY6RX3Y3HFjGEnFxyuLPCQdjvHwMEny",
        "abc",
        "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
        "175tWpb8K1S7NmH4Zx6rewF9WQrcZv245W",
    ])
    func invalidAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator
        walletCoreAddressValidator = WalletCoreAddressService(coin: .bitcoin, publicKeyType: CoinType.bitcoin.publicKeyType)
        let addressValidator = AddressServiceFactory(blockchain: blockchain).makeAddressService()

        #expect(!walletCoreAddressValidator.validate(addressHex))
        #expect(!addressValidator.validate(addressHex))
    }
}
