import Foundation
import TangemSdk
import stellarsdk
import BitcoinCore

struct BitcoinWalletAssembly: WalletManagerAssembly {
    func make(with input: WalletManagerAssemblyInput) throws -> WalletManager {
        let network: BitcoinNetwork = input.blockchain.isTestnet ? .testnet : .mainnet
        let bitcoinManager = BitcoinManager(
            networkParams: network.networkParams,
            walletPublicKey: input.wallet.publicKey.blockchainKey,
            compressedWalletPublicKey: try Secp256k1Key(with: input.wallet.publicKey.blockchainKey).compress(),
            bip: input.pairPublicKey == nil ? .bip84 : .bip141
        )

        let txBuilder = BitcoinTransactionBuilder(bitcoinManager: bitcoinManager, addresses: input.wallet.addresses)
        let providers: [AnyBitcoinNetworkProvider] = input.apiInfo.reduce(into: []) { partialResult, providerType in
            switch providerType {
            case .nowNodes:
                partialResult.append(networkProviderAssembly
                    .makeBlockBookUTXOProvider(with: input, for: .nowNodes)
                    .eraseToAnyBitcoinNetworkProvider())
            case .getBlock:
                if input.blockchain.isTestnet {
                    break
                }

                partialResult.append(networkProviderAssembly
                    .makeBlockBookUTXOProvider(with: input, for: .getBlock)
                    .eraseToAnyBitcoinNetworkProvider())
            case .blockchair:
                partialResult.append(
                    contentsOf: networkProviderAssembly.makeBlockchairNetworkProviders(
                        endpoint: .bitcoin(testnet: input.blockchain.isTestnet),
                        with: input
                    )
                )
            case .blockcypher:
                partialResult.append(
                    networkProviderAssembly.makeBlockcypherNetworkProvider(
                        endpoint: .bitcoin(testnet: input.blockchain.isTestnet),
                        with: input
                    ).eraseToAnyBitcoinNetworkProvider()
                )
            default:
                break
            }
        }

        let networkService = BitcoinNetworkService(providers: providers)

        return BitcoinWalletManager(wallet: input.wallet, txBuilder: txBuilder, networkService: networkService)
    }
}
