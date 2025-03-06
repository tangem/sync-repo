//
//  TerraAddressTests.swift
//  TangemApp
//
//  Created by Mikhail Andreev on 3/5/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing

struct TerraAddressTests {
    @Test(arguments: [Blockchain.terraV1, .terraV2])
    func address(blockchain: Blockchain) throws {
        let addressService = WalletCoreAddressService(blockchain: blockchain)
        let expectedAddress = "terra1c2zwqqucrqvvtyxfn78ajm8w2sgyjf5eax3ymk"

        let addressFromCompressedKey = try addressService.makeAddress(from: Keys.AddressesKeys.secpCompressedKey).value
        let addressFromDecompressedKey = try addressService.makeAddress(from: Keys.AddressesKeys.secpCompressedKey).value
        #expect(expectedAddress == addressFromCompressedKey)
        #expect(expectedAddress == addressFromDecompressedKey)

        #expect(throws: (any Error).self) {
            try addressService.makeAddress(from: Keys.AddressesKeys.edKey)
        }

        #expect(addressService.validate("terra1hdp298kaz0eezpgl6scsykxljrje3667d233ms"))
        #expect(addressService.validate("terravaloper1pdx498r0hrc2fj36sjhs8vuhrz9hd2cw0yhqtk"))
        #expect(!addressService.validate("cosmos1hsk6jryyqjfhp5dhc55tc9jtckygx0eph6dd02"))
    }
}
