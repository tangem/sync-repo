//
//  UserWalletRepository.swift
//  Tangem
//
//  Created by Alexander Osokin on 03.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import CryptoKit
import enum TangemSdk.EllipticCurve
import struct TangemSdk.Card
import struct TangemSdk.ExtendedPublicKey
import struct TangemSdk.WalletData
import struct TangemSdk.ArtworkInfo
import struct TangemSdk.PrimaryCard
import struct TangemSdk.DerivationPath
import struct TangemSdk.SecureStorage
import class TangemSdk.TangemSdk
import class TangemSdk.BackupService
import enum TangemSdk.TangemSdkError

import Intents

class CommonUserWalletRepository: UserWalletRepository {
    @Injected(\.tangemSdkProvider) private var sdkProvider: TangemSdkProviding
    @Injected(\.tangemApiService) private var tangemApiService: TangemApiService
    @Injected(\.backupServiceProvider) private var backupServiceProvider: BackupServiceProviding
    @Injected(\.walletConnectServiceProvider) private var walletConnectServiceProvider: WalletConnectServiceProviding
    @Injected(\.saletPayRegistratorProvider) private var saltPayRegistratorProvider: SaltPayRegistratorProviding
    @Injected(\.supportChatService) private var supportChatService: SupportChatServiceProtocol
    @Injected(\.failedScanTracker) var failedCardScanTracker: FailedScanTrackable

    weak var delegate: UserWalletRepositoryDelegate? = nil

    var selectedModel: CardViewModel? {
        return models.first {
            $0.userWallet?.userWalletId == selectedUserWalletId
        }
    }

    var selectedUserWalletId: Data?

    var isEmpty: Bool {
        userWallets.isEmpty
    }

    var eventProvider: AnyPublisher<UserWalletRepositoryEvent, Never> {
        eventSubject.eraseToAnyPublisher()
    }

    private(set) var models = [CardViewModel]()

    private(set) var isUnlocked: Bool = false

    private var userWallets: [UserWallet] = []

    private var encryptionKeyByUserWalletId: [Data: SymmetricKey] = [:]

    private let encryptionKeyStorage = UserWalletEncryptionKeyStorage()

    private var fileManager: FileManager {
        FileManager.default
    }
    private var backupService: BackupService {
        backupServiceProvider.backupService
    }
    private var userWalletDirectoryUrl: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user_wallets", isDirectory: true)
    }

    private let eventSubject = PassthroughSubject<UserWalletRepositoryEvent, Never>()

    private let minimizedAppTimer = MinimizedAppTimer(interval: 2 * 60)

    private var bag: Set<AnyCancellable> = .init()

    init() {
        let savedSelectedUserWalletId = AppSettings.shared.selectedUserWalletId
        self.selectedUserWalletId = savedSelectedUserWalletId.isEmpty ? nil : savedSelectedUserWalletId

        userWallets = savedUserWallets(withSensitiveData: false)
        bind()
    }

    deinit {
        print("UserWalletRepository deinit")
    }

    func bind() {
        minimizedAppTimer
            .timer
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.lock()
            }
            .store(in: &bag)
    }

    func scanPublisher(with batch: String? = nil) -> AnyPublisher<UserWalletRepositoryResult?, Never>  {
        Deferred {
            Future { [weak self] promise in
                self?.scanInternal(with: batch) { result in
                    switch result {
                    case .success(let scanResult):
                        promise(.success(scanResult))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .flatMap { [weak self] (response: CardViewModel) -> AnyPublisher<CardViewModel, Error> in
            let saltPayUtil = SaltPayUtil()
            let hasSaltPayBackup = self?.backupService.hasInterruptedSaltPayBackup ?? false
            let primaryCardId = self?.backupService.primaryCard?.cardId ?? ""

            if hasSaltPayBackup && response.cardId != primaryCardId  {
                return .anyFail(error: SaltPayRegistratorError.emptyBackupCardScanned)
            }

            if saltPayUtil.isBackupCard(cardId: response.cardId) {
                if let backupInput = response.backupInput, backupInput.steps.stepsCount > 0 {
                    return .anyFail(error: SaltPayRegistratorError.emptyBackupCardScanned)
                } else {
                    return .justWithError(output: response)
                }
            }

            guard let saltPayRegistrator = self?.saltPayRegistratorProvider.registrator else {
                return .justWithError(output: response)
            }

            return saltPayRegistrator.updatePublisher()
                .map { _ in
                    return response
                }
                .eraseToAnyPublisher()
        }
        .flatMap { [weak self] cardModel -> AnyPublisher<UserWalletRepositoryResult?, Error> in
            self?.failedCardScanTracker.resetCounter()

            Analytics.log(.cardWasScanned)

            let onboardingInput = cardModel.onboardingInput
            if onboardingInput.steps.needOnboarding {
                cardModel.userWalletModel?.updateAndReloadWalletModels()

                return Just(UserWalletRepositoryResult.onboarding(onboardingInput))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            return Just(.success(cardModel))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        .catch { [weak self] (error: Error) -> Just<UserWalletRepositoryResult?> in
            guard let self else {
                return Just(nil)
            }

            print("Failed to scan card: \(error)")

            self.failedCardScanTracker.recordFailure()

            if let saltpayError = error as? SaltPayRegistratorError {
                return Just(UserWalletRepositoryResult.error(saltpayError.alertBinder))
            }

            if self.failedCardScanTracker.shouldDisplayAlert {
                return Just(UserWalletRepositoryResult.troubleshooting)
            }

            switch error.toTangemSdkError() {
            case .unknownError, .cardVerificationFailed:
                return Just(UserWalletRepositoryResult.error(error.alertBinder))
            default:
                return Just(nil)
            }
        }
        .eraseToAnyPublisher()
    }

    private func scanInternal(with batch: String? = nil, _ completion: @escaping (Result<CardViewModel, Error>) -> Void) {
        Analytics.reset()
        Analytics.log(.readyToScan)
        walletConnectServiceProvider.reset()

        var config = TangemSdkConfigFactory().makeDefaultConfig()
        if AppSettings.shared.saveUserWallets {
            config.accessCodeRequestPolicy = .alwaysWithBiometrics
        }
        sdkProvider.setup(with: config)

        sendEvent(.scan(isScanning: true))
        sdkProvider.sdk.startSession(with: AppScanTask(targetBatch: batch)) { [unowned self] result in
            self.sendEvent(.scan(isScanning: false))

            switch result {
            case .failure(let error):
                Analytics.logCardSdkError(error, for: .scan)
                completion(.failure(error))
            case .success(let response):
                didScan(card: CardDTO(card: response.card), walletData: response.walletData)
                self.acceptTOSIfNeeded(response.getCardInfo(), completion)
            }
        }
    }

    func unlock(with method: UserWalletRepositoryUnlockMethod, completion: @escaping (Result<Void, Error>) -> Void) {
        switch method {
        case .biometry:
            unlockWithBiometry(completion: completion)
        case .card(let userWallet):
            unlockWithCard(userWallet, completion: completion)
        }
    }

    func didScan(card: CardDTO, walletData: DefaultWalletData) {
        let cardId = card.cardId

        let cardInfo = CardInfo(card: card, walletData: walletData, name: "")

        guard
            let userWalletId = UserWalletIdFactory().userWalletId(from: cardInfo)?.value,
            card.hasWallets,
            var userWallet = userWallets.first(where: { $0.userWalletId == userWalletId }),
            !userWallet.associatedCardIds.contains(cardId)
        else {
            return
        }

        userWallet.associatedCardIds.insert(cardId)
        save(userWallet)
    }

    func contains(_ userWallet: UserWallet) -> Bool {
        userWallets.contains { $0.userWalletId == userWallet.userWalletId }
    }

    func add(_ completion: @escaping (UserWalletRepositoryResult?) -> Void) {
        scanPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let cardModel):
                    guard let userWallet = cardModel.userWallet else { return }

                    if !self.contains(userWallet) {
                        self.save(userWallet)
                        completion(result)
                    }

                    self.setSelectedUserWalletId(userWallet.userWalletId)
                default:
                    completion(result)
                }
            }
            .store(in: &bag)
    }

    func save(_ userWallet: UserWallet) {
        if let index = userWallets.firstIndex(where: { $0.userWalletId == userWallet.userWalletId }) {
            userWallets[index] = userWallet
        } else {
            userWallets.append(userWallet)
        }

        encryptionKeyStorage.add(userWallet)

        saveUserWallets(userWallets)

        if let index = models.firstIndex(where: { $0.userWallet?.userWalletId == userWallet.userWalletId }) {
            models[index].setUserWallet(userWallet)
        } else {
            let newModel = CardViewModel(userWallet: userWallet)
            models.append(newModel)
        }

        sendEvent(.updated(userWalletId: userWallet.userWalletId))

        if userWallets.isEmpty || selectedUserWalletId == nil {
            setSelectedUserWalletId(userWallet.userWalletId)
        }
    }

    func setSelectedUserWalletId(_ userWalletId: Data?) {
        guard selectedUserWalletId != userWalletId else { return }

        if userWalletId == nil {
            selectedUserWalletId = nil
            AppSettings.shared.selectedUserWalletId = Data()
            return
        }

        guard let userWallet = userWallets.first(where: {
            $0.userWalletId == userWalletId
        }) else {
            return
        }

        let updateSelection: (UserWallet) -> Void = { [weak self] userWallet in
            self?.selectedUserWalletId = userWallet.userWalletId
            AppSettings.shared.selectedUserWalletId = userWallet.userWalletId
            self?.initializeServicesForSelectedModel()

            self?.sendEvent(.selected(userWallet: userWallet))
        }

        if !userWallet.isLocked {
            updateSelection(userWallet)
            return
        }

        unlock(with: .card(userWallet: userWallet)) { [weak self] result in
            guard
                let self,
                case .success = result,
                let selectedModel = self.models.first(where: { $0.userWallet?.userWalletId == userWallet.userWalletId }),
                let userWallet = selectedModel.userWallet
            else {
                return
            }

            updateSelection(userWallet)
        }
    }

    func delete(_ userWallet: UserWallet) {
        let userWalletId = userWallet.userWalletId
        encryptionKeyByUserWalletId[userWalletId] = nil
        userWallets.removeAll { $0.userWalletId == userWalletId }
        models.removeAll { $0.userWalletId == userWalletId }

        encryptionKeyStorage.delete(userWallet)
        saveUserWallets(userWallets)

        if selectedUserWalletId == userWalletId {
            let newSelectedUserWalletId: Data?
            if let firstMultiModel = models.first(where: { $0.isMultiWallet }) {
                newSelectedUserWalletId = firstMultiModel.userWalletId
            } else if let firstSingleModel = models.first(where: { !$0.isMultiWallet }) {
                newSelectedUserWalletId = firstSingleModel.userWalletId
            } else {
                newSelectedUserWalletId = nil
            }

            setSelectedUserWalletId(newSelectedUserWalletId)
        }

        sendEvent(.deleted(userWalletId: userWalletId))
    }

    func lock() {
        isUnlocked = false
        encryptionKeyByUserWalletId = [:]
        models = []
        userWallets = savedUserWallets(withSensitiveData: false)

        sendEvent(.locked)
    }

    func clear() {
        lock()

        saveUserWallets([])
        setSelectedUserWalletId(nil)
        encryptionKeyStorage.clear()
    }

    private func acceptTOSIfNeeded(_ cardInfo: CardInfo, _ completion: @escaping (Result<CardViewModel, Error>) -> Void) {
        let touURL = UserWalletConfigFactory(cardInfo).makeConfig().touURL

        guard let delegate, !AppSettings.shared.termsOfServicesAccepted.contains(touURL.absoluteString) else {
            completion(.success(processScan(cardInfo)))
            return
        }

        delegate.showTOS(at: touURL) { accepted in
            if accepted {
                AppSettings.shared.termsOfServicesAccepted.insert(touURL.absoluteString)
                completion(.success(self.processScan(cardInfo)))
            } else {
                completion(.failure(TangemSdkError.userCancelled))
            }
        }
    }

    // TODO: refactor
    private func startInitializingServices(for cardInfo: CardInfo) {
        let interaction = INInteraction(intent: ScanTangemCardIntent(), response: nil)
        interaction.donate(completion: nil)

        saltPayRegistratorProvider.reset()
        if let primaryCard = cardInfo.primaryCard {
            backupServiceProvider.backupService.setPrimaryCard(primaryCard)
        }
    }

    private func finishInitializingServices(for cardModel: CardViewModel, cardInfo: CardInfo) {
        tangemApiService.setAuthData(cardInfo.card.tangemApiAuthData)
        supportChatService.initialize(with: cardModel.supportChatEnvironment)
        walletConnectServiceProvider.initialize(with: cardModel)

        if SaltPayUtil().isPrimaryCard(batchId: cardInfo.card.batchId),
           let wallet = cardInfo.card.wallets.first {
            try? saltPayRegistratorProvider.initialize(cardId: cardInfo.card.cardId,
                                                       walletPublicKey: wallet.publicKey,
                                                       cardPublicKey: cardInfo.card.cardPublicKey)
        }
    }

    private func processScan(_ cardInfo: CardInfo) -> CardViewModel {
        startInitializingServices(for: cardInfo)

        // TODO: Remove CardViewModel from here, use CardInfo
        let config = UserWalletConfigFactory(cardInfo).makeConfig()
        let cardModel = CardViewModel(cardInfo: cardInfo, config: config)

        finishInitializingServices(for: cardModel, cardInfo: cardInfo)

        cardModel.didScan()
        return cardModel
    }

    private func unlockWithBiometry(completion: @escaping (Result<Void, Error>) -> Void) {
        encryptionKeyStorage.fetch { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }

                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let keys):
                    self.encryptionKeyByUserWalletId = keys
                    self.userWallets = self.savedUserWallets(withSensitiveData: true)
                    self.loadModels()
                    self.initializeServicesForSelectedModel()
                    self.isUnlocked = true
                    completion(.success(()))
                }
            }
        }
    }

    private func unlockWithCard(_ requiredUserWallet: UserWallet?, completion: @escaping (Result<Void, Error>) -> Void) {
        scanPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard
                    let self,
                    case let .success(cardModel) = result,
                    let scannedUserWallet = cardModel.userWallet,
                    let encryptionKey = scannedUserWallet.encryptionKey,
                    self.contains(scannedUserWallet)
                else {
                    completion(.failure(TangemSdkError.cardError))
                    return
                }

                if let requiredUserWallet,
                   scannedUserWallet.userWalletId != requiredUserWallet.userWalletId {
                    completion(.failure(TangemSdkError.cardError))
                    return
                }

                self.encryptionKeyByUserWalletId[scannedUserWallet.userWalletId] = encryptionKey
                self.loadModel(for: scannedUserWallet)
                self.setSelectedUserWalletId(scannedUserWallet.userWalletId)
                self.initializeServicesForSelectedModel()

                self.isUnlocked = self.userWallets.allSatisfy { !$0.isLocked }

                self.sendEvent(.updated(userWalletId: scannedUserWallet.userWalletId))

                completion(.success(()))
            }
            .store(in: &bag)
    }

    private func loadModels() {
        let models = userWallets.map {
            CardViewModel(userWallet: $0)
        }
        self.models = models
    }

    private func loadModel(for userWallet: UserWallet) {
        guard let index = userWallets.firstIndex(where: { $0.userWalletId == userWallet.userWalletId }) else { return }

        userWallets[index] = userWallet

        if models.isEmpty {
            loadModels()
        } else {
            let model = CardViewModel(userWallet: userWallet)
            models[index] = model
        }
    }

    private func initializeServicesForSelectedModel() {
        guard let selectedModel else { return }

        let cardInfo = selectedModel.cardInfo
        startInitializingServices(for: cardInfo)
        finishInitializingServices(for: selectedModel, cardInfo: cardInfo)
    }

    private func sendEvent(_ event: UserWalletRepositoryEvent) {
        eventSubject.send(event)
    }
}

// MARK: - Saving user wallets

extension CommonUserWalletRepository {
    private func savedUserWallets(withSensitiveData loadSensitiveData: Bool) -> [UserWallet] {
        do {
            guard fileManager.fileExists(atPath: userWalletListPath().path) else {
                return []
            }

            let decoder = JSONDecoder()

            let userWalletsPublicDataEncrypted = try Data(contentsOf: userWalletListPath())
            let userWalletsPublicData = try decrypt(userWalletsPublicDataEncrypted, with: publicDataEncryptionKey())
            var userWallets = try decoder.decode([UserWallet].self, from: userWalletsPublicData)

            if !loadSensitiveData {
                return userWallets
            }

            for i in 0 ..< userWallets.count {
                let userWallet = userWallets[i]

                let userWalletEncryptionKey: SymmetricKey

                if let encryptionKey = encryptionKeyByUserWalletId[userWallet.userWalletId] {
                    userWalletEncryptionKey = encryptionKey
                } else {
                    print("Failed to find encryption key for wallet", userWallet.userWalletId.hex)
                    continue
                }

                let sensitiveInformationEncryptedData = try Data(contentsOf: userWalletPath(for: userWallet))
                let sensitiveInformationData = try decrypt(sensitiveInformationEncryptedData, with: userWalletEncryptionKey)
                let sensitiveInformation = try decoder.decode(UserWallet.SensitiveInformation.self, from: sensitiveInformationData)

                var card = userWallet.card
                card.wallets = sensitiveInformation.wallets
                userWallets[i].card = card
            }

            return userWallets
        } catch {
            print(error)
            return []
        }
    }

    private func saveUserWallets(_ userWallets: [UserWallet]) {
        let encoder = JSONEncoder()

        do {
            if userWallets.isEmpty {
                if fileManager.fileExists(atPath: userWalletDirectoryUrl.path) {
                    try fileManager.removeItem(at: userWalletDirectoryUrl)
                }
                return
            }

            try fileManager.createDirectory(at: userWalletDirectoryUrl, withIntermediateDirectories: true)

            let userWalletsWithoutSensitiveInformation: [UserWallet] = userWallets.map {
                var card = $0.card
                card.wallets = []

                var userWalletWithoutKeys = $0
                userWalletWithoutKeys.card = card
                return userWalletWithoutKeys
            }

            let publicData = try encoder.encode(userWalletsWithoutSensitiveInformation)
            let publicDataEncoded = try encrypt(publicData, with: publicDataEncryptionKey())
            try publicDataEncoded.write(to: userWalletListPath(), options: .atomic)
            try excludeFromBackup(url: userWalletListPath())

            for userWallet in userWallets {
                guard let userWalletEncryptionKey = userWallet.encryptionKey else {
                    print("User wallet \(userWallet.card.cardId) failed to generate encryption key")
                    continue
                }

                let sensitiveInformation = UserWallet.SensitiveInformation(wallets: userWallet.card.wallets)
                let sensitiveDataEncoded = try encrypt(encoder.encode(sensitiveInformation), with: userWalletEncryptionKey)
                let sensitiveDataPath = userWalletPath(for: userWallet)
                try sensitiveDataEncoded.write(to: sensitiveDataPath, options: .atomic)
                try excludeFromBackup(url: sensitiveDataPath)
            }
        } catch {
            print("Failed to save user wallets", error)
        }
    }

    private func publicDataEncryptionKey() throws -> SymmetricKey {
        let keychainKey = "user_wallet_public_data_encryption_key"
        let secureStorage = SecureStorage()

        let encryptionKeyData = try secureStorage.get(keychainKey)
        if let encryptionKeyData = encryptionKeyData {
            let symmetricKey: SymmetricKey = .init(data: encryptionKeyData)
            return symmetricKey
        }

        let newEncryptionKey = SymmetricKey(size: .bits256)
        try secureStorage.store(newEncryptionKey.dataRepresentationWithHexConversion, forKey: keychainKey)
        return newEncryptionKey
    }

    private func userWalletListPath() -> URL {
        userWalletDirectoryUrl.appendingPathComponent("user_wallets.bin")
    }

    private func userWalletPath(for userWallet: UserWallet) -> URL {
        return userWalletDirectoryUrl.appendingPathComponent("user_wallet_\(userWallet.userWalletId.hex).bin")
    }

    private func excludeFromBackup(url originalUrl: URL) throws {
        var url = originalUrl

        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try url.setResourceValues(resourceValues)
    }

    private func decrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
        return decryptedData
    }

    private func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try ChaChaPoly.seal(data, using: key)
        let sealedData = sealedBox.combined
        return sealedData
    }
}
