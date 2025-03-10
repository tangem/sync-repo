//
//  TotalBalanceStateBuilder.swift
//  TangemApp
//
//  Created by Sergey Balashov on 07.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct TotalBalanceStateBuilder {
    typealias Balance = (item: TokenItem, balance: TokenBalanceType)

    private let walletModelsManager: WalletModelsManager

    init(walletModelsManager: WalletModelsManager) {
        self.walletModelsManager = walletModelsManager
    }

    func buildTotalBalanceState() -> TotalBalanceState {
        guard walletModelsManager.isInitialized else {
            // We are still waiting when list of wallet models will be created
            return .loading(cached: .none)
        }

        let balances = walletModelsManager.walletModels.map {
            TotalBalanceStateBuilder.Balance(item: $0.tokenItem, balance: $0.fiatTotalTokenBalanceProvider.balanceType)
        }

        return mapToTotalBalance(balances: balances)
    }
}

// MARK: - TotalBalanceStateBuilder

private extension TotalBalanceStateBuilder {
    func mapToTotalBalance(balances: [Balance]) -> TotalBalanceState {
        // Some not start loading yet
        let hasEmpty = balances.contains { $0.balance.isEmpty(for: .noData) }
        if hasEmpty {
            return .empty
        }

        if balances.isEmpty {
            return .loaded(balance: 0)
        }

        let hasLoading = balances.contains { $0.balance.isLoading }

        // Show it in loading state if only one is in loading process
        if hasLoading {
            let loadingBalance = cachedBalance(balances: balances.map(\.balance))
            return .loading(cached: loadingBalance)
        }

        let failureBalances = balances.filter { $0.balance.isFailure }
        let hasError = !failureBalances.isEmpty
        if hasError {
            // If has error and cached balance then show the failed state with cached balances
            let cachedBalance = cachedBalance(balances: balances.map(\.balance))
            return .failed(cached: cachedBalance, failedItems: failureBalances.map(\.item))
        }

        guard let loadedBalance = loadedBalance(balances: balances) else {
            // some tokens don't have balance
            return .empty
        }

        return .loaded(balance: loadedBalance)
    }

    func cachedBalance(balances: [TokenBalanceType]) -> Decimal? {
        let cachedBalances = balances.compactMap { balanceType in
            switch balanceType {
            case .empty(.custom), .empty(.noAccount):
                return Decimal(0)
            case .loading(.some(let cached)), .failure(.some(let cached)):
                return cached.balance
            case .loaded(let balance):
                return balance
            default:
                return nil
            }
        }

        if cachedBalances.isEmpty {
            return nil
        }

        // The cached balance is showable only if all tokens have some balance value
        if cachedBalances.count == balances.count {
            return cachedBalances.reduce(0, +)
        }

        return nil
    }

    func loadedBalance(balances: [Balance]) -> Decimal? {
        let loadedBalance = balances.compactMap { balance in
            switch balance.balance {
            case .loaded(let balance):
                return balance
            // If we don't balance because custom token don't have rates
            // Or it's address with noAccount state
            // Just calculate it as `.zero`
            case .empty(.custom), .empty(.noAccount):
                return .zero
            default:
                assertionFailure("Balance not found \(balance.item.name)")
                return nil
            }
        }

        return loadedBalance.reduce(0, +)
    }
}
