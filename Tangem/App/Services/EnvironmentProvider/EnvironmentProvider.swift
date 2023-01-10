//
//  EnvironmentProvider.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

// MARK: - Provider

class EnvironmentProvider {
    static let shared = EnvironmentProvider()
    private init() {}

    @AppStorageCompat(EnvironmentProviderKeys.testnet)
    var isTestnet: Bool = false

    @AppStorageCompat(EnvironmentProviderKeys.availableFeatures)
    var availableFeatures: Set<FeatureToggle> = []

    @AppStorageCompat(EnvironmentProviderKeys.useDevApi)
    var useDevApi = false

    @AppStorageCompat(EnvironmentProviderKeys.debugAmplitude)
    var debugAmplitude = false

    @AppStorageCompat(EnvironmentProviderKeys.debugAmplitudeName)
    var debugAmplitudeName = AmplitudeSetupUtility.defaultUserName
}

// MARK: - Keys

enum EnvironmentProviderKeys: String {
    case testnet = "testnet"
    case availableFeatures = "integrated_features"
    case useDevApi = "use_dev_api"
    case debugAmplitude = "debug-amplitude"
    case debugAmplitudeName = "debug-amplitude-name"
}
