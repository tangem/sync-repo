//
//  CardViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 18.07.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import TangemSdk
import BlockchainSdk
import Combine
import Alamofire
import SwiftUI

struct CardPinSettings {
    var isPin1Default: Bool? = nil
    var isPin2Default: Bool? = nil
}

class CardViewModel: Identifiable, ObservableObject {
    // MARK: Services
    @Injected(\.cardImageLoader) var imageLoader: CardImageLoaderProtocol
    @Injected(\.appWarningsService) private var warningsService: AppWarningsProviding
    @Injected(\.tangemSdkProvider) private var tangemSdkProvider: TangemSdkProviding
    @Injected(\.tokenItemsRepository) private var tokenItemsRepository: TokenItemsRepository
    @Injected(\.tangemApiService) var tangemApiService: TangemApiService
    @Injected(\.scannedCardsRepository) private var scannedCardsRepository: ScannedCardsRepository

    @Published var state: State = .created
    @Published var payId: PayIdStatus = .notSupported
    @Published private(set) var currentSecurityOption: SecurityModeOption = .longTap
    @Published public var cardInfo: CardInfo
    @Published var walletsBalanceState: WalletsBalanceState = .loaded

    var signer: TangemSigner

    private var walletBalanceSubscription: AnyCancellable? = nil
    private var cardPinSettings: CardPinSettings = CardPinSettings()
    private let stateUpdateQueue = DispatchQueue(label: "state_update_queue")
    private var migrated = false
    private var tangemSdk: TangemSdk { tangemSdkProvider.sdk }

    let config: UserWalletConfig

    var availableSecurityOptions: [SecurityModeOption] {
        var options: [SecurityModeOption] = []

        if canSetLongTap || currentSecurityOption == .longTap {
            options.append(.longTap)
        }

        if config.features.contains(.settingAccessCodeAllowed) || currentSecurityOption == .accessCode {
            options.append(.accessCode)
        }

        if config.features.contains(.settingPasscodeAllowed) || currentSecurityOption == .passCode {
            options.append(.passCode)
        }

        return options
    }

    var walletModels: [WalletModel]? {
        return state.walletModels
    }

    var wallets: [Wallet]? {
        return walletModels?.map { $0.wallet }
    }

    var canSetLongTap: Bool {
        return cardInfo.card.settings.isResettingUserCodesAllowed
    }

    var hasWallet: Bool {
        state.walletModels != nil
    }

    var isSuccesfullyLoaded: Bool {
        if let walletModels = state.walletModels {
            if walletModels.contains(where: { !$0.state.isSuccesfullyLoaded }) {
                return false
            }

            return true
        }

        return false
    }

    var hasBalance: Bool {
        let hasBalance = state.walletModels.map { $0.contains(where: { $0.hasBalance }) } ?? false

        return hasBalance
    }

    var canExchangeCrypto: Bool { config.features.contains(.exchangingAllowed) }

    var cachedImage: UIImage? = nil

    var imageLoaderPublisher: AnyPublisher<UIImage, Never> {
        if let cached = cachedImage {
            return Just(cached).eraseToAnyPublisher()
        }

        return $cardInfo
            .filter { $0.artwork != .notLoaded }
            .map { $0.imageLoadDTO }
            .removeDuplicates()
            .flatMap { [weak self] info -> AnyPublisher<UIImage, Never> in
                guard let self = self else {
                    return Just(UIImage()).eraseToAnyPublisher()
                }

                return self.imageLoader
                    .loadImage(cid: info.cardId,
                               cardPublicKey: info.cardPublicKey,
                               artworkInfo: info.artwotkInfo)
                    .map { [weak self] (image, canBeCached) -> UIImage in
                        if canBeCached {
                            self?.cachedImage = image
                        }

                        return image
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    private var searchBlockchainsCancellable: AnyCancellable? = nil
    private var bag = Set<AnyCancellable>()

    init(cardInfo: CardInfo) {
        self.cardInfo = cardInfo
        self.signer = .init(with: cardInfo.card)

        let configBuilder = UserWalletConfigBuilderFactory.makeBuilder(for: cardInfo)
        self.config = configBuilder.buildConfig()
        updateCardPinSettings()
        updateCurrentSecurityOption()
    }

//    func loadPayIDInfo () {
//        guard featuresService?.canReceiveToPayId ?? false else {
//            return
//        }
//
//        payIDService?
//            .loadPayIDInfo(for: cardInfo.card)
//            .subscribe(on: DispatchQueue.global())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        print("payid load failed")
//                        Analytics.log(error: error)
//                        print(error.localizedDescription)
//                    case .finished:
//                        break
//                    }}){ [unowned self] status in
//                print("payid loaded")
//                self.payId = status
//            }
//            .store(in: &bag)
//    }

//    func createPayID(_ payIDString: String, completion: @escaping (Result<Void, Error>) -> Void) { //todo: move to payidservice
//        guard featuresService.canReceiveToPayId,
//              !payIDString.isEmpty,
//              let cid = cardInfo.card.cardId,
//              let payIDService = self.payIDService,
//              let cardPublicKey = cardInfo.card.cardPublicKey,
//              let address = state.wallet?.address  else {
//            completion(.failure(PayIdError.unknown))
//            return
//        }
//
//        let fullPayIdString = payIDString + "$payid.tangem.com"
//        payIDService.createPayId(cid: cid, key: cardPublicKey,
//                                 payId: fullPayIdString,
//                                 address: address) { [weak self] result in
//            switch result {
//            case .success:
//                UIPasteboard.general.string = fullPayIdString
//                self?.payId = .created(payId: fullPayIdString)
//                completion(.success(()))
//            case .failure(let error):
//                Analytics.log(error: error)
//                completion(.failure(error))
//            }
//        }
//
//    }

    func update() -> AnyPublisher<Never, Never> {
        guard state.canUpdate else {
            return Empty().eraseToAnyPublisher()
        }

        observeBalanceLoading()

        return tryMigrateTokens()
            .flatMap { [weak self] in
                Publishers
                    .MergeMany(self?.state.walletModels?.map { $0.update() } ?? [])
                    .collect()
                    .ignoreOutput()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func refresh() -> AnyPublisher<Never, Never> {
        guard state.canUpdate else {
            return Empty().eraseToAnyPublisher()
        }

        observeBalanceLoading(showProgressLoading: false)

        return tryMigrateTokens()
            .flatMap { [weak self] in
                Publishers
                    .MergeMany(self?.state.walletModels?.map { $0.update() } ?? [])
                    .collect()
                    .ignoreOutput()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    func observeBalanceLoading(showProgressLoading: Bool = true) {
        guard let walletModels = self.state.walletModels else {
            return
        }

        if showProgressLoading {
            self.walletsBalanceState = .inProgress
        }

        walletBalanceSubscription = Publishers.MergeMany(walletModels.map({ $0.update() }))
            .collect()
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                self.walletsBalanceState = .loaded
            }
    }

    // MARK: - Security
    func changeSecurityOption(_ option: SecurityModeOption, completion: @escaping (Result<Void, Error>) -> Void) {
        switch option {
        case .accessCode:
            tangemSdk.startSession(with: SetUserCodeCommand(accessCode: nil),
                                   cardId: cardInfo.card.cardId,
                                   initialMessage: Message(header: nil, body: "initial_message_change_access_code_body".localized)) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.cardPinSettings.isPin1Default = false
                    self.cardPinSettings.isPin2Default = true
                    self.updateCurrentSecurityOption()
                    completion(.success(()))
                case .failure(let error):
                    Analytics.logCardSdkError(error, for: .changeSecOptions, card: self.cardInfo.card, parameters: [.newSecOption: "Access Code"])
                    completion(.failure(error))
                }
            }
        case .longTap:
            tangemSdk.startSession(with: SetUserCodeCommand.resetUserCodes,
                                   cardId: cardInfo.card.cardId) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.cardPinSettings.isPin1Default = true
                    self.cardPinSettings.isPin2Default = true
                    self.updateCurrentSecurityOption()
                    completion(.success(()))
                case .failure(let error):
                    Analytics.logCardSdkError(error, for: .changeSecOptions, card: self.cardInfo.card, parameters: [.newSecOption: "Long tap"])
                    completion(.failure(error))
                }
            }
        case .passCode:
            tangemSdk.startSession(with: SetUserCodeCommand(passcode: nil),
                                   cardId: cardInfo.card.cardId,
                                   initialMessage: Message(header: nil, body: "initial_message_change_passcode_body".localized)) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success:
                    self.cardPinSettings.isPin1Default = true
                    self.cardPinSettings.isPin2Default = false
                    self.updateCurrentSecurityOption()
                    completion(.success(()))
                case .failure(let error):
                    Analytics.logCardSdkError(error, for: .changeSecOptions, card: self.cardInfo.card, parameters: [.newSecOption: "Pass code"])
                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Wallet
    func createWallet(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let card = self.cardInfo.card
        tangemSdk.startSession(with: CreateWalletAndReadTask(with: config.defaultBlockchain?.curve),
                               cardId: cardInfo.card.cardId,
                               initialMessage: Message(header: nil,
                                                       body: "initial_message_create_wallet_body".localized)) { [weak self] result in
            switch result {
            case .success(let card):
                self?.update(with: card)
                completion(.success(()))
            case .failure(let error):
                Analytics.logCardSdkError(error, for: .createWallet, card: card)
                completion(.failure(error))
            }
        }
    }

    func resetToFactory(completion: @escaping (Result<Void, Error>) -> Void) {
        let card = self.cardInfo.card
        tangemSdk.startSession(with: ResetToFactorySettingsTask(),
                               cardId: cardInfo.card.cardId,
                               initialMessage: Message(header: nil,
                                                       body: "initial_message_purge_wallet_body".localized)) { [weak self] result in
            switch result {
            case .success(let response):
                self?.tokenItemsRepository.removeAll(for: response.cardId)
                self?.clearTwinPairKey()
                // self.update(with: response)
                completion(.success(()))
            case .failure(let error):
                Analytics.logCardSdkError(error, for: .purgeWallet, card: card)
                completion(.failure(error))
            }
        }
    }

    func deriveKeys(derivationPaths:  [Data: [DerivationPath]], completion: @escaping (Result<Void, Error>) -> Void) {
        let card = self.cardInfo.card

        tangemSdk.startSession(with: DeriveMultipleWalletPublicKeysTask(derivationPaths), cardId: card.cardId) { [weak self] result in
            switch result {
            case .success(let newDerivations):
                self?.updateDerivations(with: newDerivations)
                completion(.success(()))
            case .failure(let error):
                Analytics.logCardSdkError(error, for: .purgeWallet, card: card)
                completion(.failure(error))
            }
        }
    }

    func updateDerivations(with newDerivations: [Data: [DerivationPath: ExtendedPublicKey]]) {
        for newKey in newDerivations {
            for newDerivation in newKey.value {
                self.cardInfo.derivedKeys[newKey.key, default: [:]][newDerivation.key] = newDerivation.value
            }
        }

        scannedCardsRepository.add(cardInfo)
    }

    // MARK: - Update

    func getCardInfo() {
        cardInfo.artwork = .notLoaded
        guard cardInfo.card.firmwareVersion.type == .release else {
            cardInfo.artwork = .noArtwork
            return
        }

        tangemSdk.loadCardInfo(cardPublicKey: cardInfo.card.cardPublicKey, cardId: cardInfo.card.cardId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let info):
                self.cardInfo.artwork =  info.artwork.map { .artwork($0) } ?? .noArtwork
            case .failure:
                self.cardInfo.artwork = .noArtwork
                self.warningsService.setupWarnings(for: self.cardInfo)
            }
        }
    }

    func update(with card: Card) {
        print("🟩 Updating Card view model with new Card")
        cardInfo.card = card
        signer = .init(with: cardInfo.card)
        updateCardPinSettings()
        self.updateCurrentSecurityOption()
        updateModel()
    }

    func update(with cardInfo: CardInfo) {
        print("🔷 Updating Card view model with new CardInfo")
        self.cardInfo = cardInfo
        signer = .init(with: cardInfo.card)
        updateCardPinSettings()
        self.updateCurrentSecurityOption()
        updateModel()
    }

    func clearTwinPairKey() { //TODO: refactor and remove
        if case let .twin(walletData) = cardInfo.walletData {
            let newData = TwinCardInfo(cid: walletData.cid, series: walletData.series)
            cardInfo.walletData = .twin(newData)
        }
    }

    func updateState() {
        print("‼️ Updating Card view model state")
        let hasWallets = !cardInfo.card.wallets.isEmpty

        if !hasWallets {
            self.state = .empty
        } else {
            print("⁉️ Recreating all wallet models for Card view model state")
            self.state = .loaded(walletModel: WalletManagerAssembly.makeAllWalletModels(from: cardInfo))

            //TODO: Remove state, refactor and check note onboarding
           // if !AppSettings.shared.cardsStartedActivation.contains(cardInfo.card.cardId) || cardInfo.isTangemWallet {
                update()
                    .sink { _ in

                    } receiveValue: { _ in

                    }
                    .store(in: &bag)
          //  }
        }
    }

    private func updateModel() {
        print("🔶 Updating Card view model")
        warningsService.setupWarnings(for: cardInfo)
        updateState()
    }

    private func updateLoadedState(with newWalletModels: [WalletModel]) {
        stateUpdateQueue.sync {
            if let existingWalletModels = self.walletModels {
                state = .loaded(walletModel: (existingWalletModels + newWalletModels))
            }
        }
    }

    private func searchBlockchains() {
        guard config.features.contains(.tokensSearch) else { return }
    
        searchBlockchainsCancellable = nil

        guard let currentBlockhains = wallets?.map({ $0.blockchain }) else {
            return
        }

        let supportedItems = SupportedTokenItems()
        let unused: [StorageEntry] = supportedItems.blockchains(for: cardInfo.card.walletCurves, isTestnet: cardInfo.isTestnet)
            .subtracting(currentBlockhains).map { StorageEntry(blockchainNetwork: .init($0, derivationPath: nil), tokens: []) }
        let models = WalletManagerAssembly.makeWalletModels(from: cardInfo, entries: unused)
        if models.isEmpty {
            return
        }

        searchBlockchainsCancellable =
            Publishers.MergeMany(models.map { $0.update() })
                .collect(models.count)
                .sink { [weak self] _ in
                    guard let self = self else { return }

                    let notEmptyWallets = models.filter { !$0.wallet.isEmpty }
                    if !notEmptyWallets.isEmpty {
                        let itemsToAdd = notEmptyWallets.map { $0.blockchainNetwork }
                        self.tokenItemsRepository.append(itemsToAdd, for: self.cardInfo.card.cardId)
                        self.updateLoadedState(with: notEmptyWallets)
                    }
                } receiveValue: { _ in

                }
    }

    private func searchTokens() {
        guard config.features.contains(.tokensSearch),
              !AppSettings.shared.searchedCards.contains(cardInfo.card.cardId) else {
            return
        }
        
        var shouldAddWalletManager = false
        let ethBlockchain = Blockchain.ethereum(testnet: isTestnet)
        let network = BlockchainNetwork(ethBlockchain, derivationPath: nil)
        var ethWalletModel = walletModels?.first(where: { $0.blockchainNetwork == network })

        if ethWalletModel == nil {
            shouldAddWalletManager = true
            let entry = StorageEntry(blockchainNetwork: network, tokens: [])
            ethWalletModel = WalletManagerAssembly.makeWalletModels(from: cardInfo, entries: [entry]).first
        }

        guard let tokenFinder = ethWalletModel?.walletManager as? TokenFinder else {
            AppSettings.shared.searchedCards.append(self.cardInfo.card.cardId)
            self.searchBlockchains()
            return
        }


        tokenFinder.findErc20Tokens(knownTokens: []) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let tokensAdded):
                if tokensAdded {
                    let tokens = ethWalletModel!.walletManager.cardTokens
                    self.tokenItemsRepository.append(tokens, blockchainNetwork: network, for: self.cardInfo.card.cardId)

                    if shouldAddWalletManager {
                        self.stateUpdateQueue.sync {
                            self.state = .loaded(walletModel: self.walletModels! + [ethWalletModel!])
                        }
                        ethWalletModel!.update()
                    }
                }
            case .failure(let error):
                print(error)
            }

            AppSettings.shared.searchedCards.append(self.cardInfo.card.cardId)
            self.searchBlockchains()
        }
    }

    func add(items: [(Amount.AmountType, BlockchainNetwork)], completion: @escaping (Result<Void, Error>) -> Void) {
        var entries: [StorageEntry] = []

        items.forEach { item in
            if let index = entries.firstIndex(where: { $0.blockchainNetwork == item.1 }) {
                if let token = item.0.token, !entries[index].tokens.contains(token) {
                    entries[index].tokens.append(token)
                }
            } else {
                let tokens = item.0.token.map { [$0] } ?? []
                entries.append(StorageEntry(blockchainNetwork: item.1, tokens: tokens))
            }
        }

        tokenItemsRepository.append(entries, for: cardInfo.card.cardId)

        if cardInfo.card.settings.isHDWalletAllowed {
            var newDerivationPaths: [Data: [DerivationPath]] = [:]

            entries.forEach { entry in
                if let path = entry.blockchainNetwork.derivationPath,
                   let publicKey = cardInfo.card.wallets.first(where: { $0.curve == entry.blockchainNetwork.blockchain.curve })?.publicKey,
                   cardInfo.derivedKeys[publicKey]?[path] == nil {
                    newDerivationPaths[publicKey, default: []].append(path)
                }
            }

            if newDerivationPaths.isEmpty {
                finishAddingTokens(entries, completion: completion)
                return
            }

            deriveKeys(derivationPaths: newDerivationPaths) { result in
                switch result {
                case .success:
                    self.finishAddingTokens(entries, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            finishAddingTokens(entries, completion: completion)
        }
    }

    private func finishAddingTokens(_ entries: [StorageEntry], completion: @escaping (Result<Void, Error>) -> Void) {
        guard let walletModels = self.walletModels else {
            completion(.success(()))
            return
        }

        var newWalletModels: [WalletModel] = []

        entries.forEach { entry in
            if let existingWalletModel = walletModels.first(where: { $0.blockchainNetwork == entry.blockchainNetwork }) {
                existingWalletModel.addTokens(entry.tokens)
                existingWalletModel.update()
            } else {
                let wm = WalletManagerAssembly.makeWalletModels(from: cardInfo, entries: [entry])
                newWalletModels.append(contentsOf: wm)
            }
        }

        newWalletModels.forEach { $0.update() }
        updateLoadedState(with: newWalletModels)
        completion(.success(()))
    }

    func canManage(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool {
        if let walletModel = walletModels?.first(where: { $0.blockchainNetwork == blockchainNetwork }) {
            return walletModel.canRemove(amountType: amountType)
        }

        return true
    }

    func canRemove(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) -> Bool {
        if let walletModel = walletModels?.first(where: { $0.blockchainNetwork == blockchainNetwork }) {
            return walletModel.canRemove(amountType: amountType)
        }

        return false
    }

    func remove(items: [(Amount.AmountType, BlockchainNetwork)]) {
        items.forEach {
            remove(amountType: $0.0, blockchainNetwork: $0.1)
        }
    }

    func remove(amountType: Amount.AmountType, blockchainNetwork: BlockchainNetwork) {
        guard canRemove(amountType: amountType, blockchainNetwork: blockchainNetwork) else {
            assertionFailure("\(blockchainNetwork.blockchain) can't be remove")
            return
        }

        if amountType == .coin {
            removeBlockchain(blockchainNetwork)
        } else if case let .token(token) = amountType {
            removeToken(token, blockchainNetwork: blockchainNetwork)
        }
    }

    private func removeBlockchain(_ blockchainNetwork: BlockchainNetwork) {
        tokenItemsRepository.remove([blockchainNetwork], for: cardInfo.card.cardId)

        stateUpdateQueue.sync {
            if let walletModels = self.walletModels {
                state = .loaded(walletModel: walletModels.filter { $0.blockchainNetwork != blockchainNetwork })
            }
        }
    }

    private func removeToken(_ token: BlockchainSdk.Token, blockchainNetwork: BlockchainNetwork) {
        if let walletModel = walletModels?.first(where: { $0.blockchainNetwork == blockchainNetwork }) {
            let isRemoved = walletModel.removeToken(token, for: cardInfo.card.cardId)

            if isRemoved {
                stateUpdateQueue.sync {
                    if let walletModels = self.walletModels {
                        state = .loaded(walletModel: walletModels)
                    }
                }
            }
        }
    }

    private func tryMigrateTokens(completion: @escaping () -> Void) {
        if migrated {
            completion()
            return
        }

        migrated = true
        let cardId = cardInfo.card.cardId
        let items = tokenItemsRepository.getItems(for: cardId)
        let itemsWithCustomTokens = items.filter { item in
            return item.tokens.contains(where: { $0.isCustom })
        }

        if itemsWithCustomTokens.isEmpty {
            completion()
            return
        }

        let publishers = itemsWithCustomTokens.flatMap { item in
            item.tokens.filter { $0.isCustom }.map { token -> AnyPublisher<Bool, Never> in
                let requestModel = CoinsListRequestModel(
                    contractAddress: token.contractAddress,
                    networkIds: [item.blockchainNetwork.blockchain.networkId]
                )

                return tangemApiService
                    .loadCoins(requestModel: requestModel)
                    .replaceError(with: [])
                    .map { [unowned self] models -> Bool in
                        if let updatedTokem = models.first?.items.compactMap({ $0.token }).first {
                            self.tokenItemsRepository.append([updatedTokem], blockchainNetwork: item.blockchainNetwork, for: cardId)
                            return true
                        }
                        return false
                    }
                    .eraseToAnyPublisher()
            }
        }

        Publishers.MergeMany(publishers)
            .collect(publishers.count)
            .sink { [unowned self] migrationResults in
                if migrationResults.contains(true) {
                    self.state = .loaded(walletModel: WalletManagerAssembly.makeAllWalletModels(from: self.cardInfo))
                }
                completion()
            }
            .store(in: &bag)
    }

    private func tryMigrateTokens() -> AnyPublisher<Void, Never> {
        Future { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }

            self.tryMigrateTokens {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func updateCardPinSettings() {
        cardPinSettings.isPin1Default = !cardInfo.card.isAccessCodeSet
        cardInfo.card.isPasscodeSet.map { self.cardPinSettings.isPin2Default = !$0 }
    }

    func updateCurrentSecurityOption() {
        if !(cardPinSettings.isPin1Default ?? true) {
            self.currentSecurityOption = .accessCode
        } else if !(cardPinSettings.isPin2Default ?? true) {
            self.currentSecurityOption = .passCode
        }
        else {
            self.currentSecurityOption = .longTap
        }
    }
}

extension CardViewModel {
    enum State {
        case created
        case empty
        case loaded(walletModel: [WalletModel])

        var walletModels: [WalletModel]? {
            switch self {
            case .loaded(let models):
                return models
            default:
                return nil
            }
        }
        var canUpdate: Bool {
            switch self {
            case .loaded:
                return true
            default:
                return false
            }
        }
    }
}

extension CardViewModel {
    enum WalletsBalanceState {
        case inProgress
        case loaded
    }
}
