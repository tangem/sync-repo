//
//  NFTAvailabilityProvider+InjectedValues.swift
//  Tangem
//
//  Created by Andrei Fedorov on 27.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension InjectedValues {
    var nftAvailabilityProvider: NFTAvailabilityProvider {
        get { Self[NFTAvailabilityProviderKey.self] }
        set { Self[NFTAvailabilityProviderKey.self] = newValue }
    }
}

// MARK: - Private implementation

private struct NFTAvailabilityProviderKey: InjectionKey {
    static var currentValue: NFTAvailabilityProvider = CommonNFTAvailabilityProvider(appSettings: .shared)
}
