//
//  VisaPaymentAccountInteractorBuilder.swift
//  TangemVisa
//
//  Created by Andrew Son on 18/01/24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk

public struct VisaPaymentAccountInteractorBuilder {
    private let isTestnet: Bool
    private let evmSmartContractInteractor: EVMSmartContractInteractor
    private let urlSessionConfiguration: URLSessionConfiguration
    private let isMockedAPIEnabled: Bool

    public init(
        isTestnet: Bool,
        evmSmartContractInteractor: EVMSmartContractInteractor,
        urlSessionConfiguration: URLSessionConfiguration,
        isMockedAPIEnabled: Bool
    ) {
        self.isTestnet = isTestnet
        self.evmSmartContractInteractor = evmSmartContractInteractor
        self.urlSessionConfiguration = urlSessionConfiguration
        self.isMockedAPIEnabled = isMockedAPIEnabled
    }

    public func build(customerCardInfo: VisaCustomerCardInfo) async throws -> VisaPaymentAccountInteractor {
        VisaLogger.info("Start loading token info")
        let tokenInfoLoader = VisaTokenInfoLoader(
            isTestnet: isTestnet,
            evmSmartContractInteractor: evmSmartContractInteractor
        )
        let visaToken = try await tokenInfoLoader.loadTokenInfo(for: customerCardInfo.paymentAccount)

        VisaLogger.info("Creating Payment account interactor for founded PaymentAccount")
        return CommonPaymentAccountInteractor(
            customerCardInfo: customerCardInfo,
            visaToken: visaToken,
            isTestnet: isTestnet,
            evmSmartContractInteractor: evmSmartContractInteractor
        )
    }
}

public extension VisaPaymentAccountInteractorBuilder {
    enum VisaBridgeInteractorBuilderError: LocalizedError {
        case failedToFindPaymentAccount
        case failedToLoadTokenInfo(error: LocalizedError)

        public var errorDescription: String? {
            switch self {
            case .failedToFindPaymentAccount:
                return "Failed to find payment account"
            case .failedToLoadTokenInfo(let error):
                return "Failed to load token info: \(error.errorDescription ?? "unknown")"
            }
        }
    }
}
