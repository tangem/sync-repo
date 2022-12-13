//
//  DefaultExchangeManager.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 24.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class DefaultExchangeManager {
    // MARK: - Dependencies

    private let exchangeProvider: ExchangeProvider
    private let blockchainDataProvider: BlockchainDataProvider

    // MARK: - Internal

    private lazy var refreshDataTimer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    private var availabilityState: ExchangeAvailabilityState = .idle {
        didSet { delegate?.exchangeManager(self, didUpdate: availabilityState) }
    }
    private var exchangeItems: ExchangeItems {
        didSet { delegate?.exchangeManager(self, didUpdate: exchangeItems) }
    }
    private var tokenExchangeAllowanceLimit: Decimal? {
        didSet {  delegate?.exchangeManager(self, didUpdate: isAvailableForExchange()) }
    }

    private weak var delegate: ExchangeManagerDelegate?
    private var amount: Decimal?
    private var formattedAmount: String {
        guard var amount else {
            assertionFailure("Amount not set")
            return ""
        }

        let decimalValue = pow(10, exchangeItems.source.decimalCount)
        amount *= decimalValue
        return String(describing: amount)
    }

    private var walletAddress: String? {
        blockchainDataProvider.getWalletAddress(currency: exchangeItems.source)
    }

    private var refreshDataTimerBag: AnyCancellable?
    private var bag: Set<AnyCancellable> = []

    init(
        exchangeProvider: ExchangeProvider,
        blockchainInfoProvider: BlockchainDataProvider,
        exchangeItems: ExchangeItems,
        amount: Decimal? = nil
    ) {
        self.exchangeProvider = exchangeProvider
        self.blockchainDataProvider = blockchainInfoProvider
        self.exchangeItems = exchangeItems
        self.amount = amount

        updateSourceBalances()
        Task {
            await updateExchangeAmountAllowance()
        }
    }
}

// MARK: - ExchangeManager

extension DefaultExchangeManager: ExchangeManager {
    func setDelegate(_ delegate: ExchangeManagerDelegate) {
        self.delegate = delegate
    }

    func getAvailabilityState() -> ExchangeAvailabilityState {
        return availabilityState
    }

    func getExchangeItems() -> ExchangeItems {
        return exchangeItems
    }

    func isAvailableForExchange() -> Bool {
        guard exchangeItems.source.isToken, let amount, amount > 0 else {
            return true
        }

        guard let tokenExchangeAllowanceLimit else {
            return false
        }

        return amount <= tokenExchangeAllowanceLimit
    }

    func update(exchangeItems: ExchangeItems) {
        self.exchangeItems = exchangeItems
        exchangeItemsDidChange()
    }

    func update(amount: Decimal?) {
        self.amount = amount
        amountDidChange()
    }

    func refresh() {
        refreshValues(silent: true)
    }
}

// MARK: - Fields Changes

private extension DefaultExchangeManager {
    func amountDidChange() {
        updateSourceBalances()

        if amount == nil || amount == 0 {
            updateState(.idle)
            return
        }

        restartTimer()
        refreshValues(silent: false)
    }

    func exchangeItemsDidChange() {
        /// Set nil for previous token
        tokenExchangeAllowanceLimit = nil
        updateSourceBalances()

        guard (amount ?? 0) > 0 else { return }

        restartTimer()
        refreshValues(silent: false)
    }
}

// MARK: - State updates

private extension DefaultExchangeManager {
    func updateState(_ state: ExchangeAvailabilityState) {
        self.availabilityState = state
    }

    func restartTimer() {
        stopTimer()
        startTimer()
    }

    func startTimer() {
        refreshDataTimerBag = refreshDataTimer
            .upstream
            .sink { [weak self] _ in
                self?.refreshValues(silent: true)
            }
    }

    func stopTimer() {
        refreshDataTimerBag?.cancel()
        refreshDataTimer
            .upstream
            .connect()
            .cancel()
    }
}

// MARK: - Requests

private extension DefaultExchangeManager {
    func refreshValues(silent: Bool) {
        if !silent {
            updateState(.loading)
        }

        Task {
            do {
                let result = try await getExpectedSwappingResult()

                switch exchangeItems.source.currencyType {
                case .coin:
                    if result.isEnoughAmountForExchange {
                        let exchangeData = try await getExchangeTxDataModel()
                        updateState(.available(expected: result, exchangeData: exchangeData))
                    } else {
                        updateState(.preview(expected: result))
                    }
                case .token:
                    await updateExchangeAmountAllowance()
                    let approvedDataModel = try await getExchangeApprovedDataModel()
                    let spender = try await getApprovedSpenderAddress()
                    let approvedData = try mapToApprovedData(approvedDataModel: approvedDataModel, spenderAddress: spender)
                    updateState(.requiredPermission(expected: result, approvedData: approvedData))
                }
            } catch {
                updateState(.requiredRefresh(occurredError: error))
            }
        }
    }

    func updateExchangeAmountAllowance() async {
        /// If allowance limit already loaded use it
        guard tokenExchangeAllowanceLimit == nil,
              let walletAddress else {
            delegate?.exchangeManager(self, didUpdate: isAvailableForExchange())
            return
        }

        do {
            tokenExchangeAllowanceLimit = try await exchangeProvider.fetchAmountAllowance(
                for: exchangeItems.source,
                walletAddress: walletAddress
            )
        } catch {
            tokenExchangeAllowanceLimit = nil
            updateState(.requiredRefresh(occurredError: error))
        }
    }

    func getExpectedSwappingResult() async throws -> ExpectedSwappingResult {
        let quoteData = try await exchangeProvider.fetchQuote(
            items: exchangeItems,
            amount: formattedAmount
        )

        return try await mapExpectedSwappingResult(from: quoteData)
    }

    func getExchangeApprovedDataModel() async throws -> ExchangeApprovedDataModel {
        return try await exchangeProvider.fetchApproveExchangeData(for: exchangeItems.source)
    }

    func getApprovedSpenderAddress() async throws -> String {
        return try await exchangeProvider.fetchSpenderAddress(for: exchangeItems.source)
    }

    func getExchangeTxDataModel() async throws -> ExchangeDataModel {
        guard let walletAddress else {
            print("walletAddress not found")
            throw ExchangeManagerError.walletAddressNotFound
        }

        return try await exchangeProvider.fetchExchangeData(
            items: exchangeItems,
            walletAddress: walletAddress,
            amount: formattedAmount
        )
    }

    func updateSourceBalances() {
        Task {
            let source = exchangeItems.source
            let balance = try await blockchainDataProvider.getBalance(currency: source)
            var fiatBalance: Decimal = 0
            if let amount = amount  {
                fiatBalance = try await blockchainDataProvider.getFiatBalance(currency: source, amount: amount)
            }

            exchangeItems.sourceBalance = ExchangeItems.Balance(balance: balance, fiatBalance: fiatBalance)
        }
    }
}

// MARK: - Mapping

private extension DefaultExchangeManager {
    func mapExpectedSwappingResult(from quoteData: QuoteData) async throws -> ExpectedSwappingResult {
        guard var paymentAmount = Decimal(string: quoteData.fromTokenAmount),
              var expectedAmount = Decimal(string: quoteData.toTokenAmount),
              let destination = exchangeItems.destination else {
            throw ExchangeManagerError.incorrectData
        }

        var fee = Decimal(integerLiteral: quoteData.estimatedGas)

        let decimalValue = pow(10, destination.decimalCount)
        fee /= decimalValue
        paymentAmount /= decimalValue
        expectedAmount /= decimalValue

        let expectedFiatAmount = try await blockchainDataProvider.getFiatBalance(
            currency: destination,
            amount: expectedAmount
        )

        let fiatFee = try await blockchainDataProvider.getFiatBalance(
            currency: destination,
            amount: fee
        )

        let isEnoughAmountForExchange = exchangeItems.sourceBalance.balance >= paymentAmount

        return ExpectedSwappingResult(
            expectedAmount: expectedAmount,
            expectedFiatAmount: expectedFiatAmount,
            fee: fee,
            fiatFee: fiatFee,
            decimalCount: quoteData.toToken.decimals,
            isEnoughAmountForExchange: isEnoughAmountForExchange
        )
    }

    func mapToApprovedData(approvedDataModel dataModel: ExchangeApprovedDataModel, spenderAddress: String) throws -> ApprovedData {
        guard var gas = Decimal(string: dataModel.gasPrice),
              let destination = exchangeItems.destination else {
            throw ExchangeManagerError.incorrectData
        }

        guard let walletAddress = walletAddress else {
            throw ExchangeManagerError.walletAddressNotFound
        }

        let decimalValue = pow(10, destination.decimalCount)
        gas /= decimalValue

        return ApprovedData(
            oneInchTxData: dataModel.data,
            gasPrice: gas,
            spenderAddress: spenderAddress,
            tokenAddress: walletAddress
        )
    }
}
