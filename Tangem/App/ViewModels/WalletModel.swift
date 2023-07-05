//
//  WalletModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 09.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk

class WalletModel {
    @Injected(\.tangemApiService) private var tangemApiService: TangemApiService

    var walletDidChange: AnyPublisher<WalletModel.State, Never> {
        _state
            .combineLatest(rates)
            .map { $0.0 }
            .eraseToAnyPublisher()
    }

    var statePublisher: AnyPublisher<WalletModel.State, Never> {
        _state.eraseToAnyPublisher()
    }

    var state: State {
        _state.value
    }

    var transactionHistoryStatePublisher: AnyPublisher<TransactionHistoryState, Never> {
        transactionHistoryState.eraseToAnyPublisher()
    }

    private var _state: CurrentValueSubject<State, Never> = .init(.created)
    private var rates: CurrentValueSubject<[String: Decimal], Never> = .init([:])
    private var transactionHistoryState: CurrentValueSubject<TransactionHistoryState, Never> = .init(.notLoaded)

    var tokenItem: TokenItem {
        switch amountType {
        case .coin, .reserve:
            return .blockchain(wallet.blockchain)
        case .token(let token):
            return .token(token, wallet.blockchain)
        }
    }

    var name: String {
        switch amountType {
        case .coin, .reserve:
            return wallet.blockchain.displayName
        case .token(let token):
            return token.name
        }
    }

    var isMainToken: Bool {
        switch amountType {
        case .coin, .reserve:
            return true
        case .token:
            return false
        }
    }

    var balance: String {
        wallet.amounts[amountType].map { $0.string(with: 8) } ?? ""
    }

    var isZeroAmount: Bool {
        wallet.amounts[amountType]?.isZero ?? true
    }

    var fiatBalance: String {
        let amount = wallet.amounts[amountType] ?? Amount(with: wallet.blockchain, type: amountType, value: .zero)
        return getFiatFormatted(for: amount, roundingType: .defaultFiat(roundingMode: .plain)) ?? "–"
    }

    var fiatValue: Decimal {
        getFiat(for: wallet.amounts[amountType], roundingType: .defaultFiat(roundingMode: .plain)) ?? 0
    }

    var rate: String {
        guard let currencyId = currencyId(for: amountType),
              let rate = rates.value[currencyId] else {
            return ""
        }

        return rate.currencyFormatted(
            code: AppSettings.shared.selectedCurrencyCode,
            maximumFractionDigits: 2
        )
    }

    var hasPendingTx: Bool {
        wallet.hasPendingTx(for: amountType)
    }

    var wallet: Wallet { walletManager.wallet }

    var addressNames: [String] {
        wallet.addresses.map { $0.localizedName }
    }

    var defaultAddress: String {
        wallet.defaultAddress.value
    }

    var isTestnet: Bool {
        wallet.blockchain.isTestnet
    }

    var incomingPendingTransactions: [TransactionRecord] {
        wallet.pendingIncomingTransactions.map {
            TransactionRecord(
                amountType: $0.amount.type,
                destination: $0.sourceAddress,
                timeFormatted: "",
                date: $0.date,
                transferAmount: $0.amount.string(with: 8),
                transactionType: .receive,
                status: .inProgress
            )
        }
    }

    var outgoingPendingTransactions: [TransactionRecord] {
        // let txPusher = walletManager as? TransactionPusher

        return wallet.pendingOutgoingTransactions.map {
            // let isTxStuckByTime = Date().timeIntervalSince($0.date ?? Date()) > Constants.bitcoinTxStuckTimeSec

            return TransactionRecord(
                amountType: $0.amount.type,
                destination: $0.destinationAddress,
                timeFormatted: "",
                date: $0.date,
                transferAmount: $0.amount.string(with: 8),
                transactionType: .send,
                status: .inProgress
            )
        }
    }

    var transactions: [TransactionRecord] {
        // TODO: Remove after transaction history implementation in BlockchainSDK
        if FeatureStorage().useFakeTxHistory {
            return Bool.random() ? FakeTransactionHistoryFactory().createFakeTxs(currencyCode: wallet.amounts[.coin]?.currencySymbol ?? "") : []
        }

        return TransactionHistoryMapper().convertToTransactionRecords(wallet.transactions, for: wallet.addresses)
    }

    var isEmptyIncludingPendingIncomingTxs: Bool {
        wallet.isEmpty && incomingPendingTransactions.isEmpty
    }

    var blockchainNetwork: BlockchainNetwork {
        if wallet.publicKey.derivationPath == nil { // cards without hd wallet
            return BlockchainNetwork(wallet.blockchain, derivationPath: nil)
        }

        return .init(wallet.blockchain, derivationPath: wallet.publicKey.derivationPath)
    }

    var currencyId: String? {
        currencyId(for: amountType)
    }

    var qrReceiveMessage: String {
        // TODO: handle default token
        let symbol = wallet.amounts[amountType]?.currencySymbol ?? wallet.blockchain.currencySymbol

        let currencyName: String
        if case .token(let token) = amountType {
            currencyName = token.name
        } else {
            currencyName = wallet.blockchain.displayName
        }

        return Localization.addressQrCodeMessageFormat(currencyName, symbol, wallet.blockchain.displayName)
    }

    var isDemo: Bool { demoBalance != nil }
    var demoBalance: Decimal?

    let walletManager: WalletManager // TODO: Make private
    let amountType: Amount.AmountType
    let isCustom: Bool

    private var updateTimer: AnyCancellable?
    private var txHistoryUpdateSubscription: AnyCancellable?
    private var updateWalletModelBag: AnyCancellable?
    private var bag = Set<AnyCancellable>()
    private var updatePublisher: PassthroughSubject<Void, Error>?
    private var updateQueue = DispatchQueue(label: "walletModel_update_queue")

    deinit {
        AppLog.shared.debug("🗑 WalletModel deinit")
    }

    init(
        walletManager: WalletManager,
        amountType: Amount.AmountType,
        isCustom: Bool
    ) {
        self.walletManager = walletManager
        self.amountType = amountType
        self.isCustom = isCustom

        bind()
    }

    func bind() {
        AppSettings.shared
            .$selectedCurrencyCode
            .delay(for: 0.3, scheduler: DispatchQueue.main)
            .dropFirst()
            .receive(on: updateQueue)
            .setFailureType(to: Error.self)
            .flatMap { [weak self] _ in
                self?.loadRates() ?? .justWithError(output: [:])
            }
            .receive(on: updateQueue)
            .receiveValue { [weak self] in self?.updateRatesIfNeeded($0) }
            .store(in: &bag)

        walletManager.updatePublisher()
            .filter { !$0.isInitialState }
            .receive(on: updateQueue)
            .sink { [weak self] newState in
                self?.walletManagerDidUpdate(newState)
            }
            .store(in: &bag)
    }

    // MARK: - Update wallet model

    @discardableResult
    /// Do not use with flatMap
    func update(silent: Bool) -> AnyPublisher<Void, Error> {
        // If updating already in process return updating Publisher
        if let updatePublisher = updatePublisher {
            return updatePublisher.eraseToAnyPublisher()
        }

        // Keep this before the async call
        let newUpdatePublisher = PassthroughSubject<Void, Error>()
        updatePublisher = newUpdatePublisher

        if case .loading = state {
            return newUpdatePublisher.eraseToAnyPublisher()
        }

        AppLog.shared.debug("🔄 Updating wallet manager for \(name)")

        if !silent {
            updateState(.loading)
        }

        updateWalletModelBag = walletManager
            .updatePublisher()
            .filter { !$0.isInitialState }
            .setFailureType(to: Error.self)
            .combineLatest(loadRates())
            .receive(on: updateQueue)
            .sink { [weak self] completion in
                guard let self, case .failure(let error) = completion else { return }

                AppLog.shared.error(error)
                updateRatesIfNeeded([:])
                updateState(.failed(error: error.localizedDescription))
                updatePublisher?.send(completion: .failure(error))
                updatePublisher = nil

            } receiveValue: { [weak self] _, rates in
                guard let self else { return }

                updateRatesIfNeeded(rates)

                updatePublisher?.send(())
                updatePublisher?.send(completion: .finished)
                updatePublisher = nil
            }

        walletManager.update()
        return newUpdatePublisher.eraseToAnyPublisher()
    }

    private func walletManagerDidUpdate(_ walletManagerState: WalletManagerState) {
        switch walletManagerState {
        case .loaded:
            AppLog.shared.debug("🔄 Finished updating wallet model for \(name) ")

            if let demoBalance {
                walletManager.wallet.add(coinValue: demoBalance)
            }
            updateState(.idle)
        case .failed(let error):
            AppLog.shared.debug("🔄 Failed updating wallet model for \(name) ")
            switch error as? WalletError {
            case .noAccount(let message):
                updateState(.noAccount(message: message))
            default:
                updateState(.failed(error: error.detailedError.localizedDescription))
            }
        case .loading:
            updateState(.loading)
        case .initial:
            break
        }
    }

    private func updateState(_ state: State) {
        guard self.state != state else {
            AppLog.shared.debug("Duplicate request to WalletModel state")
            return
        }

        AppLog.shared.debug("🔄 Update state \(state) in WalletModel: \(blockchainNetwork.blockchain.displayName)")
        DispatchQueue.main.async { [weak self] in // captured as weak at call stack
            self?._state.value = state
        }
    }

    // MARK: - Load Rates

    private func loadRates() -> AnyPublisher<[String: Decimal], Error> {
        var currenciesToExchange = [walletManager.wallet.blockchain.currencyId]
        currenciesToExchange += walletManager.cardTokens.compactMap { $0.id }

        AppLog.shared.debug("🔄 Start loading rates for \(wallet.blockchain)")

        return tangemApiService
            .loadRates(for: currenciesToExchange)
            .replaceError(with: [:])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func updateRatesIfNeeded(_ rates: [String: Decimal]) {
        if !self.rates.value.isEmpty, rates.isEmpty {
            AppLog.shared.debug("🔴 New rates for \(wallet.blockchain) isEmpty")
            return
        }

        AppLog.shared.debug("🔄 Update rates for \(wallet.blockchain)")
        DispatchQueue.main.async {
            self.rates.value = rates
        }
    }

    func startUpdatingTimer() {
        walletManager.setNeedsUpdate()
        AppLog.shared.debug("⏰ Starting updating timer for Wallet model")
        updateTimer = Timer.TimerPublisher(
            interval: 10.0,
            tolerance: 0.1,
            runLoop: .main,
            mode: .common
        )
        .autoconnect()
        .sink { [weak self] _ in
            AppLog.shared.debug("⏰ Updating timer alarm ‼️ Wallet model will be updated")
            self?.update(silent: false)
            self?.updateTimer?.cancel()
        }
    }

    func send(_ tx: Transaction, signer: TangemSigner) -> AnyPublisher<Void, Error> {
        if isDemo {
            return signer.sign(
                hash: Data.randomData(count: 32),
                walletPublicKey: wallet.publicKey
            )
            .mapVoid()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }

        return walletManager.send(tx, signer: signer)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.startUpdatingTimer()
            })
            .receive(on: DispatchQueue.main)
            .mapVoid()
            .eraseToAnyPublisher()
    }

    func getFee(amount: Amount, destination: String) -> AnyPublisher<[Fee], Error> {
        if isDemo {
            let demoFees = DemoUtil().getDemoFee(for: walletManager.wallet.blockchain)
            return .justWithError(output: demoFees)
        }

        return walletManager.getFee(amount: amount, destination: destination)
    }
}

// MARK: - Helpers

extension WalletModel {
    private func currencyId(for amount: Amount.AmountType) -> String? {
        switch amount {
        case .coin, .reserve:
            return walletManager.wallet.blockchain.currencyId
        case .token(let token):
            return token.id
        }
    }

    func getFiatFormatted(for amount: Amount?, roundingType: AmountRoundingType) -> String? {
        return getFiat(for: amount, roundingType: roundingType)?.currencyFormatted(code: AppSettings.shared.selectedCurrencyCode)
    }

    func getFiat(for amount: Amount?, roundingType: AmountRoundingType) -> Decimal? {
        if let amount = amount {
            return getFiat(for: amount.value, currencyId: currencyId(for: amount.type), roundingType: roundingType)
        }
        return nil
    }

    func getFiat(for value: Decimal, currencyId: String?, roundingType: AmountRoundingType) -> Decimal? {
        if let currencyId = currencyId,
           let rate = rates.value[currencyId] {
            let fiatValue = value * rate
            if fiatValue == 0 {
                return 0
            }

            switch roundingType {
            case .shortestFraction(let roundingMode):
                return SignificantFractionDigitRounder(roundingMode: roundingMode).round(value: fiatValue)
            case .default(let roundingMode, let scale):
                return max(fiatValue, Decimal(1) / pow(10, scale)).rounded(scale: scale, roundingMode: roundingMode)
            }
        }
        return nil
    }

    func getCrypto(for amount: Amount?) -> Decimal? {
        guard
            let amount = amount,
            let currencyId = currencyId(for: amount.type)
        else {
            return nil
        }

        if let rate = rates.value[currencyId] {
            return (amount.value / rate).rounded(scale: amount.decimals)
        }
        return nil
    }

    func displayAddress(for index: Int) -> String {
        wallet.addresses[index].value
    }

    func shareAddressString(for index: Int) -> String {
        wallet.getShareString(for: wallet.addresses[index].value)
    }

    func exploreURL(for index: Int, token: Token? = nil) -> URL? {
        if isDemo {
            return nil
        }

        return wallet.getExploreURL(for: wallet.addresses[index].value, token: token)
    }

    func getDecimalBalance(for type: Amount.AmountType) -> Decimal? {
        return wallet.amounts[type]?.value
    }
}

// MARK: Transaction history

extension WalletModel {
    func loadTransactionHistory() -> AnyPublisher<Void, Error> {
        // TODO: Remove after transaction history implementation in BlockchainSDK
        if FeatureStorage().useFakeTxHistory {
            return loadFakeTransactionHistory()
        }

        guard
            blockchainNetwork.blockchain.canLoadTransactionHistory,
            let historyLoader = walletManager as? TransactionHistoryLoader
        else {
            DispatchQueue.main.async {
                self.transactionHistoryState.value = .notSupported
            }
            return .justWithError(output: ())
        }

        guard txHistoryUpdateSubscription == nil else {
            return .justWithError(output: ())
        }

        transactionHistoryState.value = .loading
        let historyPublisher = historyLoader.loadTransactionHistory()
        txHistoryUpdateSubscription = historyPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    AppLog.shared.debug("🔄 Failed to load transaction history. Error: \(error)")
                    self?.transactionHistoryState.value = .failedToLoad(error)
                }
                self?.txHistoryUpdateSubscription = nil
            } receiveValue: { [weak self] _ in
                self?.transactionHistoryState.value = .loaded
            }

        return historyPublisher
            .replaceError(with: [])
            .mapVoid()
            .eraseError()
            .eraseToAnyPublisher()
    }

    // MARK: - Fake tx history related

    private func loadFakeTransactionHistory() -> AnyPublisher<Void, Error> {
        // TODO: Remove after transaction history implementation in BlockchainSDK
        guard FeatureStorage().useFakeTxHistory else {
            return .anyFail(error: "Can't use fake history")
        }

        switch transactionHistoryState.value {
        case .notLoaded, .notSupported:
            transactionHistoryState.value = .loading
            return Just(())
                .delay(for: 5, scheduler: DispatchQueue.main)
                .map {
                    self.transactionHistoryState.value = .failedToLoad("Failed to load tx history")
                    return ()
                }
                .eraseError()
                .eraseToAnyPublisher()
        case .failedToLoad:
            transactionHistoryState.value = .loading
            return Just(())
                .delay(for: 5, scheduler: DispatchQueue.main)
                .map {
                    self.transactionHistoryState.value = .loaded
                    return ()
                }
                .eraseError()
                .eraseToAnyPublisher()
        case .loaded:
            transactionHistoryState.value = .loading
            return Just(())
                .delay(for: 5, scheduler: DispatchQueue.main)
                .map {
                    self.transactionHistoryState.value = .notSupported
                    return ()
                }
                .eraseError()
                .eraseToAnyPublisher()
        case .loading:
            return Just(())
                .delay(for: 5, scheduler: DispatchQueue.main)
                .map {
                    self.transactionHistoryState.value = .loaded
                    return ()
                }
                .eraseError()
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - States

extension WalletModel {
    enum State: Hashable {
        case created
        case idle
        case loading
        case noAccount(message: String)
        case failed(error: String)
        case noDerivation

        var isLoading: Bool {
            switch self {
            case .loading, .created:
                return true
            default:
                return false
            }
        }

        var isSuccesfullyLoaded: Bool {
            switch self {
            case .idle, .noAccount:
                return true
            default:
                return false
            }
        }

        var isBlockchainUnreachable: Bool {
            switch self {
            case .failed:
                return true
            default:
                return false
            }
        }

        var isNoAccount: Bool {
            switch self {
            case .noAccount:
                return true
            default:
                return false
            }
        }

        var errorDescription: String? {
            switch self {
            case .failed(let localizedDescription):
                return localizedDescription
            case .noAccount(let message):
                return message
            default:
                return nil
            }
        }

        var failureDescription: String? {
            switch self {
            case .failed(let localizedDescription):
                return localizedDescription
            default:
                return nil
            }
        }

        fileprivate var canCreateOrPurgeWallet: Bool {
            switch self {
            case .failed, .loading, .created, .noDerivation:
                return false
            case .noAccount, .idle:
                return true
            }
        }
    }

    enum WalletManagerUpdateResult: Hashable {
        case success
        case noAccount(message: String)
    }
}

extension WalletModel: Equatable {
    static func == (lhs: WalletModel, rhs: WalletModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension WalletModel: Identifiable {
    var id: Int {
        Id(blockchainNetwork: blockchainNetwork, amountType: amountType).id
    }
}

extension WalletModel: Hashable {
    func hash(into hasher: inout Hasher) {
        let id = Id(blockchainNetwork: blockchainNetwork, amountType: amountType)
        id.hash(into: &hasher)
    }
}

extension WalletModel {
    enum TransactionHistoryState {
        case notSupported
        case notLoaded
        case loading
        case failedToLoad(Error)
        case loaded
    }
}

extension WalletModel {
    struct Id: Hashable, Identifiable {
        var id: Int { hashValue }

        let blockchainNetwork: BlockchainNetwork
        let amountType: Amount.AmountType

        func hash(into hasher: inout Hasher) {
            hasher.combine(blockchainNetwork)
            hasher.combine(amountType)
        }
    }
}
