//
//  AmplitudeSetupUtility.swift
//  Tangem
//
//  Created by Andrew Son on 10/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Amplitude

struct AmplitudeSetupUtility {
    static let defaultUserName = "iOS Developer"

    func setup(with userId: String? = nil) {
        let key = try! CommonKeysManager().amplitudeApiKey

        if AppEnvironment.current.isProduction {
            Amplitude.instance().trackingSessionEvents = true
            Amplitude.instance().initializeApiKey(key)
        } else if EnvironmentProvider.shared.debugAmplitude {
            Amplitude.instance().trackingSessionEvents = true
            let amplitudeUserId = userId ?? EnvironmentProvider.shared.debugAmplitudeName
            let isAmplitudeInitialized = !Amplitude.instance().apiKey.isEmpty
            if isAmplitudeInitialized {
                Amplitude.instance().setUserId(amplitudeUserId)
            } else {
                Amplitude.instance().initializeApiKey(key, userId: amplitudeUserId)
            }

            if Amplitude.instance().optOut {
                Amplitude.instance().optOut = false
            }

            EnvironmentProvider.shared.debugAmplitudeName = amplitudeUserId
        }
    }

    func disableAmplitude() {
        if AppEnvironment.current.isProduction {
            return
        }

        Amplitude.instance().trackingSessionEvents = false
        Amplitude.instance().optOut = true
    }
}
