import Foundation
import TangemSdk
@testable import BlockchainSdk
import Testing
import WalletCore

struct TezosAddressTests {
    private let curves: [EllipticCurve] = [.ed25519, .ed25519_slip0010]

    @Test
    func secpAddress() throws {
        // given
        let service = TezosAddressService(curve: .secp256k1)

        // when
        let addr_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        let addr_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)

        // then
        #expect(addr_dec.value == addr_comp.value)
        #expect(addr_dec.localizedName == addr_comp.localizedName)
        #expect(addr_dec.value == "tz2SdMQ72FP39GB1Cwyvs2BPRRAMv9M6Pc6B")
        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test(arguments: [EllipticCurve.ed25519, .ed25519_slip0010])
    func edAddress(curve: EllipticCurve) throws {
        // given
        let service = TezosAddressService(curve: curve)

        // when
        let address = try service.makeAddress(from: Keys.AddressesKeys.edKey)

        // then
        #expect(address.localizedName == AddressType.default.defaultLocalizedName)
        #expect(address.value == "tz1VS42nEFHoTayE44ZKANQWNhZ4QbWFV8qd")
        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)
        }
        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        }
    }

    @Test(arguments: [
        "tz1d1qQL3mYVuiH4JPFvuikEpFwaDm85oabM",
    ])
    func validAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator = WalletCoreAddressService(coin: .tezos, publicKeyType: CoinType.tezos.publicKeyType)

        curves.forEach {
            let addressValidator = AddressServiceFactory(blockchain: .tezos(curve: $0)).makeAddressService()

            #expect(walletCoreAddressValidator.validate(addressHex))
            #expect(addressValidator.validate(addressHex))
        }
    }

    @Test(arguments: [
        "tz1eZwq8b5cvE2bPKokatLkVMzkxz24z3AAAA",
        "1tzeZwq8b5cvE2bPKokatLkVMzkxz24zAAAAA",
    ])
    func invalidAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator = WalletCoreAddressService(coin: .tezos, publicKeyType: CoinType.tezos.publicKeyType)

        curves.forEach {
            let addressValidator = AddressServiceFactory(blockchain: .tezos(curve: $0)).makeAddressService()

            #expect(!walletCoreAddressValidator.validate(addressHex))
            #expect(!addressValidator.validate(addressHex))
        }
    }
}
