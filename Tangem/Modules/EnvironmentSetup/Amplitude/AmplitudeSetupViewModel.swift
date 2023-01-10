//
//  AmplitudeSetupViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 10/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import Amplitude

protocol AmplitudeSetupModelProtocol: ObservableObject {
    var userId: String { get set }
    var isOn: Bool { get set }
    var isToastPresenting: Bool { get set }
    var toastMessage: String { get }

    func updateUserId()
    func sendGatheredEvents()
}

class AmplitudeSetupViewModel: AmplitudeSetupModelProtocol, Identifiable {
    @Published var userId: String = Amplitude.instance().userId ?? ""
    @Published var isOn: Bool = EnvironmentProvider.shared.debugAmplitude {
        didSet {
            EnvironmentProvider.shared.debugAmplitude = isOn
            updateAmplitudeState()
        }
    }
    @Published var isToastPresenting: Bool = false

    var toastMessage: String = ""

    func updateUserId() {
        if userId.isEmpty {
            userId = AmplitudeSetupUtility.defaultUserName
        }
        AmplitudeSetupUtility().setup(with: userId)
        toastMessage = "User ID updated to: \(Amplitude.instance().userId ?? "empty value")"
        isToastPresenting = true
    }

    func sendGatheredEvents() {
        Amplitude.instance().uploadEvents()
        toastMessage = "Sending events to Amplitude. It can take some time"
        isToastPresenting = true
    }

    private func updateAmplitudeState() {
        if isOn {
            AmplitudeSetupUtility().setup()
            userId = Amplitude.instance().userId ?? AmplitudeSetupUtility.defaultUserName
        } else {
            AmplitudeSetupUtility().disableAmplitude()
        }
    }
}
