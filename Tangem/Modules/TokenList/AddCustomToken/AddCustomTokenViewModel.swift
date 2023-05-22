//
//  AddCustomTokenViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 11/02/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk
import struct TangemSdk.DerivationPath
import enum TangemSdk.TangemSdkError

class AddCustomTokenViewModel: ObservableObject {
    @Injected(\.tangemApiService) var tangemApiService: TangemApiService

    unowned var cardModel: CardViewModel

    @Published var name = ""
    @Published var symbol = ""
    @Published var contractAddress = ""
    @Published var decimals = ""
    @Published var customDerivationPath = ""

    @Published var blockchainsPicker: PickerModel = .empty
    @Published var derivationsPicker: PickerModel = .empty

    @Published var error: AlertBinder?

    @Published var warningContainer = WarningsContainer()
    @Published var addButtonDisabled = false
    @Published var isLoading = false

    var canEnterTokenDetails: Bool {
        selectedBlockchainSupportsTokens
    }

    var showDerivationPaths: Bool {
        cardHasDifferentDerivationPaths && blockchainHasDifferentDerivationPaths
    }

    var showCustomDerivationPath: Bool {
        derivationsPicker.selection == customDerivationItemID
    }

    @Published private var cardHasDifferentDerivationPaths: Bool = true
    @Published private var blockchainHasDifferentDerivationPaths: Bool = true

    private var selectedBlockchainSupportsTokens: Bool {
        let blockchain = try? enteredBlockchain()
        return blockchain?.canHandleTokens ?? false
    }

    private var bag: Set<AnyCancellable> = []
    private var blockchainByName: [String: Blockchain] = [:]
    private var derivationPathByBlockchainName: [String: DerivationPath] = [:]
    private var foundStandardToken: CoinModel?
    private unowned let coordinator: AddCustomTokenRoutable

    private let defaultDerivationItemID = "default-derivation"
    private let customDerivationItemID = "custom-derivation"

    init(cardModel: CardViewModel, coordinator: AddCustomTokenRoutable) {
        self.coordinator = coordinator
        self.cardModel = cardModel

        $contractAddress.removeDuplicates()
            .dropFirst()
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .flatMap { [unowned self] contractAddress -> AnyPublisher<[CoinModel], Never> in
                self.isLoading = true

                guard !contractAddress.isEmpty else {
                    return Just([])
                        .eraseToAnyPublisher()
                }

                return self.findToken(contractAddress: contractAddress)
            }
            .receive(on: RunLoop.main)
            .sink { [unowned self] currencyModels in
                self.didFinishTokenSearch(currencyModels)
            }
            .store(in: &bag)

        Publishers.CombineLatest3(
            $blockchainsPicker.map { $0.selection }.removeDuplicates(),
            $derivationsPicker.map { $0.selection }.removeDuplicates(),
            $customDerivationPath.removeDuplicates()
        )
        .debounce(for: 0.1, scheduler: RunLoop.main)
        .sink { [unowned self] _ in
            self.didChangeBlockchain()
        }
        .store(in: &bag)
    }

    func createToken() {
        UIApplication.shared.endEditing()

        let tokenItem: TokenItem
        let blockchain: Blockchain
        let derivationPath: DerivationPath?
        do {
            tokenItem = try enteredTokenItem()
            blockchain = try enteredBlockchain()
            derivationPath = try enteredDerivationPath()

            if case .token(_, let blockchain) = tokenItem,
               case .solana = blockchain,
               !cardModel.longHashesSupported {
                throw TokenCreationErrors.tokensNotSupported
            }
        } catch {
            self.error = error.alertBinder
            return
        }

        let blockchainNetwork = cardModel.getBlockchainNetwork(for: blockchain, derivationPath: derivationPath)
        let entry = StorageEntry(blockchainNetwork: blockchainNetwork, token: tokenItem.token)

        cardModel.add(entries: [entry]) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.closeModule()

                self.logSuccess(tokenItem: tokenItem, derivationPath: derivationPath)
            case .failure(let error):
                if case TangemSdkError.userCancelled = error {
                    return
                }

                self.error = error.alertBinder
            }
        }
    }

    func onAppear() {
        Analytics.log(.customTokenScreenOpened)
        updateBlockchains(getBlockchains())
        updateDerivationPaths()
    }

    func onDisappear() {
        blockchainsPicker = .empty
        derivationsPicker = .empty
        name = ""
        symbol = ""
        contractAddress = ""
        decimals = ""
    }

    private func updateBlockchains(_ blockchains: Set<Blockchain>, newSelectedBlockchain: Blockchain? = nil) {
        let defaultItem = (Localization.customTokenNetworkInputNotSelected, "")

        let newBlockchains = [defaultItem] + blockchains.sorted {
            $0.displayName < $1.displayName
        }.map {
            ($0.displayName, $0.codingKey)
        }
        self.blockchainByName = Dictionary(uniqueKeysWithValues: blockchains.map {
            ($0.codingKey, $0)
        })
        self.derivationPathByBlockchainName = Dictionary(uniqueKeysWithValues: blockchains.compactMap {
            guard let derivationPath = $0.derivationPath() else { return nil }
            return ($0.codingKey, derivationPath)
        })

        var newBlockchainName = self.blockchainsPicker.selection
        if let newSelectedBlockchain = newSelectedBlockchain {
            newBlockchainName = newSelectedBlockchain.codingKey
        } else if blockchains.count == 1, let firstBlockchain = blockchains.first {
            newBlockchainName = firstBlockchain.codingKey
        } else if blockchainByName[blockchainsPicker.selection] == nil {
            newBlockchainName = ""
        }

        self.blockchainsPicker = .init(items: newBlockchains, selection: newBlockchainName, isEnabled: blockchains.count > 1)
    }

    private func getBlockchains() -> Set<Blockchain> {
        return cardModel.supportedBlockchains
    }

    private func updateDerivationPaths() {
        let defaultItem = (Localization.customTokenDerivationPathDefault, defaultDerivationItemID)

        #warning("L10N")
        let customItem = ("Custom", customDerivationItemID)

        let derivations: [(String, String)]
        if !cardModel.hdWalletsSupported {
            derivations = []
        } else {
            derivations = getBlockchains()
                .compactMap {
                    guard let derivationPath = $0.derivationPath() else {
                        return nil
                    }

                    let derivationPathFormatted = derivationPath.rawPath
                    let blockchainName = $0.codingKey
                    let description = "\($0.displayName)\n(\(derivationPathFormatted))"
                    return (description, blockchainName)
                }
                .sorted {
                    $0.0 < $1.0
                }
        }

        let uniqueDerivations = Set(derivations.map(\.1))
        self.cardHasDifferentDerivationPaths = uniqueDerivations.count > 1
        let newDerivationSelection = self.derivationsPicker.selection
        self.derivationsPicker = .init(items: [defaultItem, customItem] + derivations, selection: newDerivationSelection)
    }

    private func enteredTokenItem() throws -> TokenItem {
        let blockchain = try enteredBlockchain()

        if !blockchain.canHandleTokens || (contractAddress.isEmpty && name.isEmpty && symbol.isEmpty && decimals.isEmpty) {
            return .blockchain(blockchain)
        } else {
            let enteredContractAddress = try self.enteredContractAddress(in: blockchain)

            guard !name.isEmpty, !symbol.isEmpty, !decimals.isEmpty else {
                throw TokenCreationErrors.emptyFields
            }

            let maxDecimalNumber = 30
            guard
                let decimals = Int(decimals),
                0 <= decimals, decimals <= maxDecimalNumber
            else {
                throw TokenCreationErrors.invalidDecimals(precision: maxDecimalNumber)
            }

            let foundStandardTokenItem = foundStandardToken?.items.first(where: { $0.blockchain == blockchain })

            let token = Token(
                name: name,
                symbol: symbol.uppercased(),
                contractAddress: enteredContractAddress,
                decimalCount: decimals,
                id: foundStandardTokenItem?.id
            )

            return .token(token, blockchain)
        }
    }

    private func validateEnteredContractAddress() throws {
        guard !contractAddress.isEmpty else {
            return
        }

        guard foundStandardToken != nil else {
            throw TokenSearchError.failedToFindToken
        }

        do {
            let blockchain = try enteredBlockchain()
            _ = try enteredContractAddress(in: blockchain)
        } catch {
            throw TokenSearchError.failedToFindToken
        }
    }

    private func validateDerivationPath() throws {
        guard customDerivationItemID == derivationsPicker.selection else {
            return
        }

        let derivationPath = try? DerivationPath(rawPath: customDerivationPath)
        if derivationPath == nil {
            throw DerivationPathError.invalidDerivationPath
        }
    }

    private func enteredBlockchain() throws -> Blockchain {
        guard let blockchain = blockchainByName[blockchainsPicker.selection] else {
            throw TokenCreationErrors.blockchainNotSelected
        }

        return blockchain
    }

    private func enteredContractAddress(in blockchain: Blockchain) throws -> String {
        if case .binance = blockchain, !contractAddress.trimmed().isEmpty {
            return contractAddress // skip validation for binance
        }

        guard blockchain.validate(address: contractAddress) else {
            throw TokenCreationErrors.invalidContractAddress
        }

        return contractAddress
    }

    private func enteredDerivationPath() throws -> DerivationPath? {
        let derivationItemID = derivationsPicker.selection

        switch derivationItemID {
        case defaultDerivationItemID:
            return nil
        case customDerivationItemID:
            return try? DerivationPath(rawPath: customDerivationPath)
        default:
            // ID is a blockchain name
            return derivationPathByBlockchainName[derivationItemID]
        }
    }

    private func checkLocalStorage() throws {
        guard let blockchain = try? enteredBlockchain() else {
            return
        }

        let cardTokenItems = cardModel.userTokenListManager.getEntriesFromRepository()

        let checkingContractAddress = !contractAddress.isEmpty
        let derivationPath = try? enteredDerivationPath()

        let blockchainNetwork = cardModel.getBlockchainNetwork(for: blockchain, derivationPath: derivationPath)

        if let networkItem = cardTokenItems.first(where: { $0.blockchainNetwork == blockchainNetwork }) {
            if !checkingContractAddress {
                throw TokenSearchError.alreadyAdded
            }

            if networkItem.tokens.contains(where: { $0.contractAddress == contractAddress }) {
                throw TokenSearchError.alreadyAdded
            }
        }
    }

    private func findToken(contractAddress: String) -> AnyPublisher<[CoinModel], Never> {
        if let currentCurrencyModel = foundStandardToken,
           let token = currentCurrencyModel.items.first?.token,
           token.contractAddress.caseInsensitiveCompare(contractAddress) == .orderedSame {
            return Just([currentCurrencyModel])
                .eraseToAnyPublisher()
        }

        let networkIds = getBlockchains().map { $0.networkId }
        let requestModel = CoinsListRequestModel(
            contractAddress: contractAddress,
            networkIds: networkIds
        )

        return tangemApiService
            .loadCoins(requestModel: requestModel)
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }

    private func didFinishTokenSearch(_ currencyModels: [CoinModel]) {
        isLoading = false

        let previouslyFoundStandardToken = foundStandardToken

        let currencyModelBlockchains = currencyModels.reduce(Set<Blockchain>()) { partialResult, currencyModel in
            partialResult.union(currencyModel.items.map { $0.blockchain })
        }

        let blockchains = getBlockchains()
        updateBlockchains(blockchains, newSelectedBlockchain: currencyModelBlockchains.first)

        self.foundStandardToken = currencyModels.first

        if let token = foundStandardToken?.items.first?.token {
            decimals = "\(token.decimalCount)"
            symbol = token.symbol
            name = token.name

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIApplication.shared.endEditing()
            }
        } else if previouslyFoundStandardToken != nil || !selectedBlockchainSupportsTokens {
            decimals = ""
            symbol = ""
            name = ""
        }

        validate()
    }

    private func didChangeBlockchain() {
        blockchainHasDifferentDerivationPaths = true

        validate()
    }

    private func validate() {
        addButtonDisabled = false
        warningContainer.removeAll()

        do {
            try validateDerivationPath()
            try checkLocalStorage()
            try validateEnteredContractAddress()
        } catch {
            let dynamicValidationError = error as? DynamicValidationError
            addButtonDisabled = dynamicValidationError?.preventsFromAdding ?? false

            if let localizedError = error as? LocalizedError {
                let warning = AppWarning(title: Localization.commonWarning, message: localizedError.localizedDescription, priority: .warning)
                warningContainer.add(warning)
            }
        }
    }

    private func logSuccess(tokenItem: TokenItem, derivationPath: DerivationPath?) {
        var params: [Analytics.ParameterKey: String] = [
            .token: tokenItem.currencySymbol,
        ]

        if let derivationStyle = cardModel.derivationStyle,
           let usedDerivationPath = derivationPath ?? tokenItem.blockchain.derivationPath(for: derivationStyle)
        {
            params[.derivationPath] = usedDerivationPath.rawPath
        }

        if case .token(let token, let blockchain) = tokenItem {
            params[.networkId] = blockchain.networkId
            params[.contractAddress] = token.contractAddress
        }

        Analytics.log(event: .customTokenWasAdded, params: params)
    }
}

// MARK: - Navigation

extension AddCustomTokenViewModel {
    func closeModule() {
        coordinator.closeModule()
    }
}

fileprivate protocol DynamicValidationError {
    var preventsFromAdding: Bool { get }
}

private extension AddCustomTokenViewModel {
    enum TokenCreationErrors: LocalizedError {
        case blockchainNotSelected
        case emptyFields
        case tokensNotSupported
        case invalidDecimals(precision: Int)
        case invalidContractAddress
        case invalidDerivationPath

        var errorDescription: String? {
            switch self {
            case .blockchainNotSelected:
                return Localization.customTokenCreationErrorNetworkNotSelected
            case .emptyFields:
                return Localization.customTokenCreationErrorEmptyFields
            case .tokensNotSupported:
                return Localization.alertManageTokensUnsupportedMessage
            case .invalidDecimals(let precision):
                return Localization.customTokenCreationErrorWrongDecimals(precision)
            case .invalidContractAddress:
                return Localization.customTokenCreationErrorInvalidContractAddress
            case .invalidDerivationPath:
                return Localization.customTokenCreationErrorInvalidDerivationPath
            }
        }
    }

    enum TokenSearchError: DynamicValidationError, LocalizedError {
        case alreadyAdded
        case failedToFindToken

        var preventsFromAdding: Bool {
            switch self {
            case .alreadyAdded:
                return true
            case .failedToFindToken:
                return false
            }
        }

        var errorDescription: String? {
            switch self {
            case .failedToFindToken:
                return Localization.customTokenValidationErrorNotFound
            case .alreadyAdded:
                return Localization.customTokenValidationErrorAlreadyAdded
            }
        }
    }

    enum DerivationPathError: DynamicValidationError, LocalizedError {
        case invalidDerivationPath

        var preventsFromAdding: Bool {
            switch self {
            case .invalidDerivationPath:
                return true
            }
        }

        var errorDescription: String? {
            switch self {
            case .invalidDerivationPath:
                #warning("L10n")
                return "The derivation path you've entered is not valid"
            }
        }
    }
}

struct PickerModel: Identifiable {
    let id = UUID()
    let items: [(String, String)]
    var selection: String
    var isEnabled: Bool = true

    static var empty: PickerModel {
        .init(items: [], selection: "")
    }
}
