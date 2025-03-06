//
//  BlockchainSdkTests.swift
//  BlockchainSdkTests
//
//  Created by Alexander Osokin on 04.12.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import BitcoinCore
import TangemSdk
@testable import BlockchainSdk
import Testing

struct BlockchainSdkTests {
    @Test
    func btcAddress() throws {
        let btcAddress = "1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs"
        let publicKey = Data(hex: "0250863ad64a87ae8a2fe83c1af1a8403cb53f53e486d8511dad8a04887e5b2352")
        let service = BitcoinLegacyAddressService(networkParams: BitcoinNetwork.mainnet.networkParams)
        #expect(try service.makeAddress(from: publicKey).value == btcAddress)
    }

    @Test
    func ducatusAddressValidation() {
        let service = AddressServiceFactory(blockchain: .ducatus).makeAddressService()
        #expect(service.validate("LokyqymHydUE3ZC1hnZeZo6nuART3VcsSU"))
    }

    @Test
    func LTCAddressValidation() {
        let service = BitcoinAddressService(networkParams: LitecoinNetworkParams())
        #expect(service.validate("LMbRCidgQLz1kNA77gnUpLuiv2UL6Bc4Q2"))
    }

    @Test
    func ethChecksum() throws {
        let blockchain = Blockchain.ethereum(testnet: false)
        let addressService = AddressServiceFactory(blockchain: blockchain).makeAddressService()
        let ethAddressService = try #require(addressService as? EthereumAddressService)
        let chesksummed = ethAddressService.toChecksumAddress("0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359")
        #expect(chesksummed == "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359")

        #expect(ethAddressService.validate("0xfb6916095ca1df60bb79ce92ce3ea74c37c5d359"))
        #expect(ethAddressService.validate("0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359"))

        let testCases = [
            "0x52908400098527886E0F7030069857D2E4169EE7",
            "0x8617E340B3D01FA5F11F306F4090FD50E238070D",
            "0xde709f2102306220921060314715629080e2fb77",
            "0x27b1fdb04752bbc536007a920d24acb045561c26",
            "0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed",
            "0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359",
            "0xdbF03B407c01E7cD3CBea99509d93f8DDDC8C6FB",
            "0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb",
        ]

        _ = testCases.map {
            let checksummed = ethAddressService.toChecksumAddress($0)
            #expect(checksummed != nil)
            #expect(ethAddressService.validate($0))
            #expect(ethAddressService.validate(checksummed!))
        }

        #expect(!ethAddressService.validate("0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9adb"))
    }

    @Test
    func rskChecksum() {
        let rskAddressService = RskAddressService()
        let publicKey = Data(hex: "04BAEC8CD3BA50FDFE1E8CF2B04B58E17041245341CD1F1C6B3A496B48956DB4C896A6848BCF8FCFC33B88341507DD25E5F4609386C68086C74CF472B86E5C3820")
        let chesksummed = try! rskAddressService.makeAddress(from: publicKey)

        #expect(chesksummed.value == "0xc63763572D45171E4C25cA0818B44e5DD7f5c15b")

        let correctAddress = "0xc63763572d45171e4c25ca0818b44e5dd7f5c15b"
        let correctAddressWithChecksum = "0xc63763572D45171E4C25cA0818B44e5DD7f5c15b"

        #expect(rskAddressService.validate(correctAddress))
        #expect(rskAddressService.validate(correctAddressWithChecksum))
    }

    @Test
    func txValidation() {
        let wallet = Wallet(
            blockchain: .bitcoin(testnet: false),
            addresses: [.default: PlainAddress(
                value: "adfjbajhfaldfh",
                publicKey: .init(seedKey: Data(), derivationType: .none),
                type: .default
            )]
        )

        let walletManager: TransactionValidator = BaseManager(wallet: wallet)
        walletManager.wallet.add(coinValue: 10)

        #expect(throws: Never.self) {
            try walletManager.validate(
                amount: Amount(with: walletManager.wallet.amounts[.coin]!, value: 3),
                fee: Fee(Amount(with: walletManager.wallet.amounts[.coin]!, value: 3))
            )
        }

        assert(
            try walletManager.validate(
                amount: Amount(with: walletManager.wallet.amounts[.coin]!, value: -1),
                fee: Fee(Amount(with: walletManager.wallet.amounts[.coin]!, value: 3))
            ),
            throws: ValidationError.invalidAmount
        )

        assert(
            try walletManager.validate(
                amount: Amount(with: walletManager.wallet.amounts[.coin]!, value: 1),
                fee: Fee(Amount(with: walletManager.wallet.amounts[.coin]!, value: -1))
            ),
            throws: ValidationError.invalidFee
        )

        assert(
            try walletManager.validate(
                amount: Amount(with: walletManager.wallet.amounts[.coin]!, value: 11),
                fee: Fee(Amount(with: walletManager.wallet.amounts[.coin]!, value: 1))
            ),
            throws: ValidationError.amountExceedsBalance
        )

        assert(
            try walletManager.validate(
                amount: Amount(with: walletManager.wallet.amounts[.coin]!, value: 1),
                fee: Fee(Amount(with: walletManager.wallet.amounts[.coin]!, value: 11))
            ),
            throws: ValidationError.feeExceedsBalance
        )

        assert(
            try walletManager.validate(
                amount: Amount(with: walletManager.wallet.amounts[.coin]!, value: 3),
                fee: Fee(Amount(with: walletManager.wallet.amounts[.coin]!, value: 8))
            ),
            throws: ValidationError.totalExceedsBalance
        )
    }

    @Test
    func derivationStyle() {
        let legacy: DerivationStyle = .v1
        let new: DerivationStyle = .v2

        let fantom: Blockchain = .fantom(testnet: false)
        #expect(fantom.derivationPath(for: legacy)!.rawPath == "m/44'/1007'/0'/0/0")
        #expect(fantom.derivationPath(for: new)!.rawPath == "m/44'/60'/0'/0/0")

        let eth: Blockchain = .ethereum(testnet: false)
        #expect(eth.derivationPath(for: legacy)!.rawPath == "m/44'/60'/0'/0/0")
        #expect(eth.derivationPath(for: new)!.rawPath == "m/44'/60'/0'/0/0")

        let ethTest: Blockchain = .ethereum(testnet: true)
        #expect(ethTest.derivationPath(for: legacy)!.rawPath == "m/44'/1'/0'/0/0")
        #expect(ethTest.derivationPath(for: new)!.rawPath == "m/44'/1'/0'/0/0")

        let xrp: Blockchain = .xrp(curve: .secp256k1)
        #expect(xrp.derivationPath(for: legacy)!.rawPath == "m/44'/144'/0'/0/0")
        #expect(xrp.derivationPath(for: new)!.rawPath == "m/44'/144'/0'/0/0")
    }

    private func assert(
        _ expression: @autoclosure () throws -> Void,
        throws error: ValidationError
    ) {
        var thrownError: Error?

        #expect(
            performing: { try expression() },
            throws: { error in
                thrownError = error
                return true
            }
        )
        #expect(thrownError as? ValidationError == error)
    }
}
