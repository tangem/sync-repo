//
//  ProductActivationServiceBuilder.swift
//  TangemVisa
//
//  Created by Andrew Son on 04/02/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

struct ProductActivationServiceBuilder {
    private let isMockAPIEnabled: Bool

    init(isMockAPIEnabled: Bool) {
        self.isMockAPIEnabled = isMockAPIEnabled
    }

    func build(urlSessionConfiguration: URLSessionConfiguration, authorizationTokensHandler: VisaAuthorizationTokensHandler) -> ProductActivationService {
        if isMockAPIEnabled {
            return ProductActivationServiceMock()
        }

        return CommonProductActivationService(
            authorizationTokensHandler: authorizationTokensHandler,
            apiService: .init(
                provider: MoyaProviderBuilder().buildProvider(configuration: urlSessionConfiguration),
                decoder: JSONDecoder()
            )
        )
    }
}
