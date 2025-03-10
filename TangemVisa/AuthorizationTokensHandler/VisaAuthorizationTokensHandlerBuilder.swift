//
//  VisaAuthorizationTokensHandlerBuilder.swift
//  TangemVisa
//
//  Created by Andrew Son on 19/02/25.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

public struct VisaAuthorizationTokensHandlerBuilder {
    private let isMockedAPIEnabled: Bool

    public init(isMockedAPIEnabled: Bool) {
        self.isMockedAPIEnabled = isMockedAPIEnabled
    }

    public func build(
        cardId: String,
        cardActivationStatus: VisaCardActivationLocalState,
        refreshTokenSaver: VisaRefreshTokenSaver?,
        urlSessionConfiguration: URLSessionConfiguration
    ) -> VisaAuthorizationTokensHandler {
        let authorizationTokensHolder: AuthorizationTokensHolder
        if let authorizationTokens = cardActivationStatus.authTokens {
            authorizationTokensHolder = .init(authorizationTokens: authorizationTokens)
        } else {
            authorizationTokensHolder = .init()
        }

        let authorizationTokenRefreshService = VisaAPIServiceBuilder(mockedAPI: isMockedAPIEnabled)
            .buildAuthorizationTokenRefreshService(urlSessionConfiguration: urlSessionConfiguration)

        let authorizationTokensHandler = CommonVisaAuthorizationTokensHandler(
            cardId: cardId,
            authorizationTokensHolder: authorizationTokensHolder,
            tokenRefreshService: authorizationTokenRefreshService,
            refreshTokenSaver: refreshTokenSaver
        )

        return authorizationTokensHandler
    }
}
