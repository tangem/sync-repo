//
//  VisaCustomerCardInfoProvider.swift
//  TangemVisa
//
//  Created by Andrew Son on 19/02/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

public protocol VisaCustomerCardInfoProvider {
    func loadPaymentAccount(cardId: String, cardWalletAddress: String) async throws -> VisaCustomerCardInfo
}

struct CommonCustomerCardInfoProvider {
    private let isTestnet: Bool
    private let authorizationTokensHandler: VisaAuthorizationTokensHandler?
    private let customerInfoManagementService: CustomerInfoManagementService?
    private let evmSmartContractInteractor: EVMSmartContractInteractor

    init(
        isTestnet: Bool,
        authorizationTokensHandler: VisaAuthorizationTokensHandler?,
        customerInfoManagementService: CustomerInfoManagementService?,
        evmSmartContractInteractor: EVMSmartContractInteractor
    ) {
        self.isTestnet = isTestnet
        self.authorizationTokensHandler = authorizationTokensHandler
        self.customerInfoManagementService = customerInfoManagementService
        self.evmSmartContractInteractor = evmSmartContractInteractor
    }
}

extension CommonCustomerCardInfoProvider: VisaCustomerCardInfoProvider {
    func loadPaymentAccount(cardId: String, cardWalletAddress: String) async throws -> VisaCustomerCardInfo {
        do {
            return try await loadPaymentAccountFromCIM(cardId: cardId, cardWalletAddress: cardWalletAddress)
        } catch let error as VisaPaymentAccountAddressProviderError {
            VisaLogger.error("Missing information for selected card", error: error)
            if error != .bffIsNotAvailable {
                throw error
            }
        } catch {
            VisaLogger.error("Failed to load payment account info from CIM. Continuing with registry", error: error)
        }

        let paymentAccount = try await loadPaymentAccountFromRegistry(cardWalletAddress: cardWalletAddress)
        return VisaCustomerCardInfo(
            paymentAccount: paymentAccount,
            cardId: cardId,
            cardWalletAddress: cardWalletAddress,
            customerInfo: nil
        )
    }

    private func getCustomerId() async throws -> String {
        guard let authorizationTokensHandler else {
            throw VisaPaymentAccountAddressProviderError.bffIsNotAvailable
        }

        if await !authorizationTokensHandler.containsAccessToken {
            try await authorizationTokensHandler.forceRefreshToken()
        }

        guard let accessToken = await authorizationTokensHandler.accessToken else {
            throw VisaAuthorizationTokensHandlerError.missingAccessToken
        }

        guard let customerId = JWTTokenHelper().getCustomerID(from: accessToken) else {
            throw VisaAuthorizationTokensHandlerError.missingMandatoryInfoInAccessToken
        }

        return customerId
    }

    private func loadPaymentAccountFromCIM(cardId: String, cardWalletAddress: String) async throws -> VisaCustomerCardInfo {
        guard let customerInfoManagementService else {
            throw VisaPaymentAccountAddressProviderError.bffIsNotAvailable
        }

        let customerId = try await getCustomerId()
        let customerInfo = try await customerInfoManagementService.loadCustomerInfo(customerId: customerId)

        guard let productInstance = customerInfo.productInstances?.first(where: { $0.cid == cardId }) else {
            throw VisaPaymentAccountAddressProviderError.missingProductInstanceForCardId
        }

        guard
            let paymentAccount = customerInfo.paymentAccounts?.first(where: { $0.id == productInstance.paymentAccountId })
        else {
            throw VisaPaymentAccountAddressProviderError.missingPaymentAccountForCard
        }

        return VisaCustomerCardInfo(
            paymentAccount: paymentAccount.paymentAccountAddress,
            cardId: cardId,
            cardWalletAddress: cardWalletAddress,
            customerInfo: customerInfo
        )
    }

    private func loadPaymentAccountFromRegistry(cardWalletAddress: String) async throws -> String {
        VisaLogger.info("Start searching PaymentAccount for card")
        let registryAddress = try VisaConfigProvider.shared().getRegistryAddress(isTestnet: isTestnet)
        VisaLogger.info("Requesting PaymentAccount from bridge")

        let request = VisaSmartContractRequest(
            contractAddress: registryAddress,
            method: GetPaymentAccountByCardMethod(cardWalletAddress: cardWalletAddress)
        )

        do {
            let response = try await evmSmartContractInteractor.ethCall(request: request).async()
            let paymentAccount = try AddressParser(isTestnet: isTestnet).parseAddressResponse(response)
            VisaLogger.info("PaymentAccount founded")
            return paymentAccount
        } catch {
            VisaLogger.error("Failed to receive PaymentAccount", error: error)
            throw error
        }
    }
}
