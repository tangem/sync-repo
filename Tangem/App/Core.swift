//
//  Core.swift
//  Tangem
//
//  Created by Alexander Osokin on 08.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk

//MARK: - UserWalletRepository

protocol UserWalletRepository {
    var userWallets: Published<[UserWallet1]>.Publisher { get }

    func lock()
    /// Throws UserWalletRepositoryError
    func unlock(with method: AuthenticationMethod) async throws

    func addUserWallet(_ userWallet: UserWallet1)
    func deleteUserWallet(_ userWallet: UserWallet1)
}

enum UserWalletRepositoryError {
    case empty(CardData)
    case unknown(CardData)
}

//MARK: - UserWallet

class UserWallet1 {
    @Published public var tokens: [UserToken1] = []

    private let context: UserWalletContext

    private let userTokensRepository: UserTokensRepository
    private let keysRepository: KeysRepository
    private let ratesProvider: RatesProvider
    private let blockchainService: BlockchainService

    init(context: UserWalletContext,
         userTokensRepository: UserTokensRepository,
         keysRepository: KeysRepository,
         ratesProvider: RatesProvider,
         blockchainService: BlockchainService) {
        self.context = context
        self.userTokensRepository = userTokensRepository
        self.keysRepository = keysRepository
        self.ratesProvider = ratesProvider
        self.blockchainService = blockchainService
    }

    func unlock(with encryptionKey: Data) {
        guard keysRepository.isLocked else { return }

        keysRepository.unlock(with: encryptionKey)
    }
}

struct UserWalletContext {

}

//MARK: - UserTokensRepository

protocol UserTokensRepository {
    var userTokens: Published<[UserToken]>.Publisher { get }

    func add(_ userToken: UserToken)
    func delete(_ userToken: UserToken)
    func sync()

    func setGroup()
    func moveToken(from source: IndexSet, to destination: Int)
}

typealias UserToken = StorageEntry

//MARK: - KeysRepository

protocol KeysRepository {
    var isLocked: Bool { get }

    func lock()
    func unlock(with encryptionKey: Data)

    func add(_ key: Key)
    func getKey(curve: EllipticCurve, path: DerivationPath) -> Key
}

struct Key {
    let curve: EllipticCurve
    let seedKey: Data
    let chainCode: Data?
    let derivedKeys: [DerivationPath: ExtendedPublicKey]
}

//MARK: - UserWalletFactory

protocol UserWalletFactory {
    func makeUserWallet(from cardData: CardData) -> UserWallet1
}

//MARK: - Authentication

protocol UserWalletAuthenticator {  
    func authenticate(with method: AuthenticationMethod) async -> [AuthData]
}

enum AuthenticationMethod {
    case biometrics
    case card(_ cardData: CardData)
}

struct AuthData {
    let userWalletId: UserWalletId
    let encryptionKey: Data
}

//MARK: - Scan

protocol CardScanner {
    func scan() async -> CardData
}

struct CardData {
    let card: Card
    let walletData: DefaultWalletData
}

//MARK: - Misc

protocol RatesProvider {

}

protocol BlockchainService {

}

protocol UserToken {
    var address: String { get }
    var balance: Decimal? { get }
    var rate: Decimal? { get }
}
