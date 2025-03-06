//
//  DecimalAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/5/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing

struct DecimalAddressTests {
    @Test
    func decimalAddressService() throws {
        let walletPublicKey = Data(hexString: "04BAEC8CD3BA50FDFE1E8CF2B04B58E17041245341CD1F1C6B3A496B48956DB4C896A6848BCF8FCFC33B88341507DD25E5F4609386C68086C74CF472B86E5C3820"
        )

        let addressService = DecimalAddressService()
        let plainAddress = try addressService.makeAddress(from: walletPublicKey)

        let expectedAddress = "d01ccmkx4edg5t3unp9egyp3dzwthtlts2m320gh9"

        #expect(plainAddress.value == expectedAddress)

        #expect(throws: (any Error).self) {
            try addressService.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test
    func decimalValidateCorrectAddressWithChecksum() throws {
        #expect(DecimalAddressService().validate("0xc63763572D45171e4C25cA0818b44E5Dd7F5c15B"))
        #expect(DecimalAddressService().validate("d01ccmkx4edg5t3unp9egyp3dzwthtlts2m320gh9"))

        #expect(!DecimalAddressService().validate("0xc63763572D45171e4C25cA0818b4"))
        #expect(!DecimalAddressService().validate("d01ccmkx4edg5t3unp9egyp3dzwtht"))
        #expect(!DecimalAddressService().validate(""))
    }

    @Test
    func testDecimalValidateConverterAddressUtils() throws {
        let converter = DecimalAddressConverter()

        let ercAddress = try converter.convertToDecimalAddress("0xc63763572d45171e4c25ca0818b44e5dd7f5c15b")
        #expect(ercAddress == "d01ccmkx4edg5t3unp9egyp3dzwthtlts2m320gh9")

        let dscAddress = try converter.convertToETHAddress("d01ccmkx4edg5t3unp9egyp3dzwthtlts2m320gh9")
        #expect(dscAddress == "0xc63763572d45171e4c25ca0818b44e5dd7f5c15b")
    }
}
