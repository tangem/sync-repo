//
//  UserWalletModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.08.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import BlockchainSdk
import Combine
import TangemSdk

protocol UserWalletModel: MainHeaderSupplementInfoProvider, TotalBalanceProviding, MultiWalletMainHeaderSubtitleDataSource, AnalyticsContextDataProvider, MainHeaderUserWalletStateInfoProvider, EmailDataProvider, WalletConnectUserWalletInfoProvider, KeysDerivingProvider, AnyObject {
    var hasBackupCards: Bool { get }
    var config: UserWalletConfig { get }
    var userWalletId: UserWalletId { get }
    var tangemApiAuthData: TangemApiTarget.AuthData { get }
    var walletModelsManager: WalletModelsManager { get }
    var userTokensManager: UserTokensManager { get }
    var userTokenListManager: UserTokenListManager { get }
    var keysRepository: KeysRepository { get }
    var refcodeProvider: RefcodeProvider { get }
    var signer: TangemSigner { get }
    var updatePublisher: AnyPublisher<Void, Never> { get }
    var backupInput: OnboardingInput? { get } // TODO: refactor
    var cardImagePublisher: AnyPublisher<CardImageResult, Never> { get }
    var totalSignedHashes: Int { get }
    var name: String { get }
    func validate() -> Bool
    func onBackupUpdate(type: BackupUpdateType)
    func updateWalletName(_ name: String)
    func addAssociatedCard(_ cardId: String)
}

enum BackupUpdateType {
    case primaryCardBackuped(card: Card)
    case backupCompleted
}
