//
//  FilecoinAddressTests.swift
//  BlockchainSdkTests
//
//  Created by Aleksei Muraveinik on 25.08.24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import XCTest
@testable import BlockchainSdk
import Testing

struct FilecoinAddressTests {
    private let addressService = WalletCoreAddressService(blockchain: .filecoin)

    @Test
    func makeAddress() throws {
        let publicKey = Data(hex: "038A3F02BEBAFD04C1FA82184BA3950C801015A0B61A0922110D7CEE42A2A13763")
        let expectedAddress = "f1hbyibpq4mea6l3no7aag24hxpwgf4zwp6msepwi"

        let address = try addressService.makeAddress(from: publicKey).value
        #expect(address == expectedAddress)
    }

    @Test(arguments: [
        "f15ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7pdrq",
        "f12fiakbhe2gwd5cnmrenekasyn6v5tnaxaqizq6a",
        "f1wbxhu3ypkuo6eyp6hjx6davuelxaxrvwb2kuwva",
        "f17uoq6tp427uzv7fztkbsnn64iwotfrristwpryy",
    ])
    func addressIsValid(addressHex: String) throws {
        #expect(addressService.validate(addressHex))
    }

    @Test(arguments: [
        "f0-1",
        "f018446744073709551616",
        "f4f77777777vnmsana",
        "t15ihq5ibzwki2b4ep2f46avlkrqzhpqgtga7pdrq",
    ])
    func addressIsInvalid(addressHex: String) throws {
        #expect(!addressService.validate(addressHex))
    }
}
