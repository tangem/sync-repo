//
//  OnboardingCoordinatorView.swift
//  Tangem
//
//  Created by Alexander Osokin on 14.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct OnboardingCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: OnboardingCoordinator

    @ViewBuilder
    var content: some View {
        if let singleCardViewModel = coordinator.singleCardViewModel {
            SingleCardOnboardingView(viewModel: singleCardViewModel)
        } else if let twinsViewModel = coordinator.twinsViewModel {
            TwinsOnboardingView(viewModel: twinsViewModel)
        } else if let walletViewModel = coordinator.walletViewModel {
            WalletOnboardingView(viewModel: walletViewModel)
        }
    }
    
//    var isNavigationBarHidden: Bool {
//        if navigation.readToMain {
//            return false
//        }
//
//        return true
//    }
//
    var body: some View {
        content
            .transition(.withoutOpacity)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
    }
}
