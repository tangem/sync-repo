//
//  CommonOnrampManager.swift
//  TangemApp
//
//  Created by Sergey Balashov on 02.10.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import TangemFoundation

public actor CommonOnrampManager {
    private let apiProvider: ExpressAPIProvider
    private let onrampRepository: OnrampRepository
    private let dataRepository: OnrampDataRepository
    private let analyticsLogger: ExpressAnalyticsLogger

    public init(
        apiProvider: ExpressAPIProvider,
        onrampRepository: OnrampRepository,
        dataRepository: OnrampDataRepository,
        analyticsLogger: ExpressAnalyticsLogger
    ) {
        self.apiProvider = apiProvider
        self.onrampRepository = onrampRepository
        self.dataRepository = dataRepository
        self.analyticsLogger = analyticsLogger
    }
}

// MARK: - OnrampManager

extension CommonOnrampManager: OnrampManager {
    public func initialSetupCountry() async throws -> OnrampCountry {
        let country = try await apiProvider.onrampCountryByIP()
        return country
    }

    public func setupProviders(request item: OnrampPairRequestItem) async throws -> ProvidersList {
        let pairs = try await apiProvider.onrampPairs(
            from: item.fiatCurrency,
            to: [item.destination.expressCurrency],
            country: item.country
        )

        let supportedProviders = pairs.flatMap { $0.providers }
        OnrampLogger.info(self, "Load pairs with supported providers \(supportedProviders)")
        guard !supportedProviders.isEmpty else {
            // Exclude unnecessary requests
            return []
        }

        // Return the `providers` with all possible options
        let providers = try await prepareProviders(item: item, supportedProviders: supportedProviders)
        return providers
    }

    public func setupQuotes(in providers: ProvidersList, amount: OnrampUpdatingAmount) async throws -> (list: ProvidersList, provider: OnrampProvider) {
        OnrampLogger.info(self, "Start update quotes for amount: \(amount)")
        try await updateQuotesInEachManager(providers: providers, amount: amount)
        OnrampLogger.info(self, "The quotes was updated for amount: \(amount)")

        providers.updateSupportedPaymentMethods()
        let sorted = providers.sorted()
        let suggestProvider = try suggestProvider(in: sorted)
        return (list: sorted, provider: suggestProvider)
    }

    public func suggestProvider(in providers: ProvidersList, paymentMethod: OnrampPaymentMethod) throws -> OnrampProvider {
        OnrampLogger.info(self, "Payment method was updated by user to: \(paymentMethod.name)")

        guard let providerItem = providers.select(for: paymentMethod) else {
            throw OnrampManagerError.noProviderForPaymentMethod
        }

        providerItem.updateAttractiveTypes()
        OnrampLogger.info(self, "Providers for paymentMethod: \(providerItem.paymentMethod.name) was sorted to order: \(providerItem.providers)")

        guard let selectedProvider = providerItem.maxPriorityProvider() else {
            throw OnrampManagerError.noProviderForPaymentMethod
        }

        OnrampLogger.info(self, "New selected provider was updated to: \(selectedProvider as Any)")
        return selectedProvider
    }

    public func loadRedirectData(provider: OnrampProvider, redirectSettings: OnrampRedirectSettings) async throws -> OnrampRedirectData {
        do {
            let item = try provider.makeOnrampQuotesRequestItem()
            let requestItem = OnrampRedirectDataRequestItem(quotesItem: item, redirectSettings: redirectSettings)
            let data = try await apiProvider.onrampData(item: requestItem)
            return data
        } catch let error as ExpressAPIError {
            analyticsLogger.logExpressAPIError(error, provider: provider.provider, paymentMethod: provider.paymentMethod)
            throw error
        } catch {
            analyticsLogger.logAppError(error, provider: provider.provider)
            throw error
        }
    }
}

// MARK: - Private

private extension CommonOnrampManager {
    func updateQuotesInEachManager(providers: ProvidersList, amount: OnrampUpdatingAmount) async throws {
        if providers.isEmpty {
            throw OnrampManagerError.providersIsEmpty
        }

        await withTaskGroup(of: Void.self) { group in
            providers.flatMap { $0.providers }.forEach { provider in
                _ = group.addTaskUnlessCancelled {
                    await provider.update(amount: amount)
                }
            }
        }
    }

    func suggestProvider(in providers: ProvidersList) throws -> OnrampProvider {
        OnrampLogger.info(self, "Start to find the best provider")

        for provider in providers {
            provider.updateAttractiveTypes()
            OnrampLogger.info(self, "Providers for paymentMethod: \(provider.paymentMethod.name) was sorted to order: \(provider.providers)")

            if let maxPriorityProvider = provider.maxPriorityProvider() {
                OnrampLogger.info(self, "The selected max priority provider is \(maxPriorityProvider)")
                return maxPriorityProvider
            }
        }

        OnrampLogger.info(self, "We couldn't find any provider without error")
        OnrampLogger.info(self, "Start the second search to find any provider to show user")

        for provider in providers {
            if let suggestProvider = provider.selectableProvider() {
                OnrampLogger.info(self, "Then update selected provider to \(suggestProvider as Any)")
                return suggestProvider
            }
        }

        OnrampLogger.info(self, "We couldn't find any provider to suggest")
        throw OnrampManagerError.suggestedProviderNotFound
    }

    func prepareProviders(item: OnrampPairRequestItem, supportedProviders: [OnrampPair.Provider]) async throws -> ProvidersList {
        // Start two async requests
        async let providersList = dataRepository.providers()
        async let paymentMethodsList = dataRepository.paymentMethods()

        let providers = try await providersList.toSet()
        let paymentMethods = try await paymentMethodsList.toSet()

        let fullfilled: [ExpressProvider: [OnrampPaymentMethod]] = supportedProviders.reduce(into: [:]) { result, supportedProvider in
            if let provider = providers.first(where: { $0.id == supportedProvider.id }) {
                let paymentMethods = supportedProvider.paymentMethods.compactMap { paymentMethodId in
                    paymentMethods.first(where: { $0.id == paymentMethodId })
                }
                result[provider] = paymentMethods
            }
        }

        let supportedPaymentMethods = fullfilled.values.flatMap { $0 }.unique()

        let availableProviders: ProvidersList = supportedPaymentMethods.map { paymentMethod in
            let providers = providers.map { provider in
                OnrampProvider(
                    provider: provider,
                    paymentMethod: paymentMethod,
                    manager: makeOnrampProviderManager(
                        item: item,
                        provider: provider,
                        paymentMethod: paymentMethod,
                        supportedProviders: supportedProviders,
                        supportedPaymentMethods: fullfilled[provider] ?? []
                    )
                )
            }
            return ProviderItem(paymentMethod: paymentMethod, providers: providers)
        }

        OnrampLogger.info(self, "Built providers \(availableProviders)")

        return availableProviders
    }

    func makeOnrampProviderManager(
        item: OnrampPairRequestItem,
        provider: ExpressProvider,
        paymentMethod: OnrampPaymentMethod,
        supportedProviders: [OnrampPair.Provider],
        supportedPaymentMethods: [OnrampPaymentMethod]
    ) -> OnrampProviderManager {
        let state: OnrampProviderManagerState = {
            guard let supportedProvider = supportedProviders.first(where: { $0.id == provider.id }) else {
                return .notSupported(.currentPair)
            }

            let isSupportedForPaymentMethods = supportedProvider.paymentMethods.contains { $0 == paymentMethod.id }
            guard isSupportedForPaymentMethods else {
                return .notSupported(.paymentMethod(supportedMethods: supportedPaymentMethods))
            }

            return .idle
        }()

        return CommonOnrampProviderManager(
            pairItem: item,
            expressProvider: provider,
            paymentMethod: paymentMethod,
            apiProvider: apiProvider,
            analyticsLogger: analyticsLogger,
            state: state
        )
    }
}

extension CommonOnrampManager: @preconcurrency CustomStringConvertible {
    public var description: String { objectDescription(self) }
}
