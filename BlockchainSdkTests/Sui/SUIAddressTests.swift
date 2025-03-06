//
//  SUIAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/5/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import stellarsdk
import TangemSdk
@testable import BlockchainSdk
import Testing

struct SUIAddressTests {
    @Test
    func address() throws {
        let walletPublicKey = Wallet.PublicKey(seedKey: .init(hex: "85ebd1441fe4f954fbe5dc6077bf008e119a5e269297c6f7083d001d2ac876fe"), derivationType: nil)
        let address = try SuiAddressService().makeAddress(for: walletPublicKey, with: .default)

        #expect(address.value == "0x54e80d76d790c277f5a44f3ce92f53d26f5894892bf395dee6375988876be6b2")
    }

    @Test(arguments: [
        "0x2347dcfa4c0d4bd1a45e9cadbd1adea820c4ee2937d65ef5cedf661f43bea8c6",
        "0x0000000000000000000000000000000000000000000000000000000000000000",
        "0xa7f81d798f047dbfcf5aa54d22e32f528b4ed0131eb157f65f2e04b79541d26a",
        "0xffd4f043057226453aeba59732d41c6093516f54823ebc3a16d17f8a77d2f0ad",
    ])
    func addressValid(addressHex: String) {
        // 32byte
        #expect(SuiAddressService().validate(addressHex))
    }

    @Test(arguments: [
        "0x",
        "0xa7bfcf5aa54d22e32f528b4ed0131eb157f65f2e04b79541d26a",
    ])
    func addressinvalid(addressHex: String) {
        #expect(!SuiAddressService().validate(addressHex))
    }
}
