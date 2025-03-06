@testable import BlockchainSdk
import TangemSdk
import Testing

struct BinanceAddressTests {
    @Test
    func mainnet() throws {
        // given
        let blockchain = Blockchain.binance(testnet: false)
        let service = BinanceAddressService(testnet: false)

        // when
        let addr_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        let addr_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)

        // then
        #expect(addr_dec.value == addr_comp.value)
        #expect(addr_dec.localizedName == addr_comp.localizedName)
        #expect(addr_dec.type == addr_comp.type)
        #expect(addr_dec.value == "bnb1c2zwqqucrqvvtyxfn78ajm8w2sgyjf5eex5gcc")
        try #expect(addressesUtility.makeTrustWalletAddress(publicKey: Keys.AddressesKeys.secpDecompressedKey, for: blockchain) == addr_dec.value)
        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test
    func testnet() throws {
        // given
        let service = BinanceAddressService(testnet: true)

        // when
        let addr_dec = try service.makeAddress(from: Keys.AddressesKeys.secpDecompressedKey)
        let addr_comp = try service.makeAddress(from: Keys.AddressesKeys.secpCompressedKey)

        // then
        #expect(addr_dec.value == addr_comp.value)
        #expect(addr_dec.localizedName == addr_comp.localizedName)
        #expect(addr_dec.type == addr_comp.type)
        #expect(addr_dec.value == "tbnb1c2zwqqucrqvvtyxfn78ajm8w2sgyjf5ehnavcf") // TODO: validate
        #expect(throws: (any Error).self) {
            try service.makeAddress(from: Keys.AddressesKeys.edKey)
        }
    }

    @Test(arguments: [
        "bnb1c2zwqqucrqvvtyxfn78ajm8w2sgyjf5eex5gcc",
    ])
    func validAddresses(addressHex: String) {
        let walletCoreAddressValidator: AddressValidator
        walletCoreAddressValidator = WalletCoreAddressService(coin: .binance, publicKeyType: CoinType.binance.publicKeyType)
        let addressValidator = AddressServiceFactory(blockchain: .binance(testnet: false)).makeAddressService()

        #expect(!walletCoreAddressValidator.validate(addressHex))
        #expect(!addressValidator.validate(addressHex))
    }
}
