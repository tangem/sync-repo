//
//  AmplitudeSetupViewModelMock.swift
//  Tangem
//
//  Created by Andrew Son on 10/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

class AmplitudeSetupViewModelMock: AmplitudeSetupModelProtocol {
    @Published var userId: String = ""
    @Published var isOn: Bool = false
    @Published var isToastPresenting: Bool = false

    var toastMessage: String {
        isSuccess ?
            "User id updated to: \(userId)" :
            "Failed to update user id"
    }

    private var isSuccess = false

    func updateUserId() {
        isSuccess.toggle()
        isToastPresenting.toggle()
    }

    func sendGatheredEvents() {
    }
}
