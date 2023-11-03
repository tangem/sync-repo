//
//  AppCoordinatorView.swift
//  Tangem
//
//  Created by Alexander Osokin on 20.06.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI

struct AppCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        NavigationView {
            if let welcomeCoordinator = coordinator.welcomeCoordinator {
                WelcomeCoordinatorView(coordinator: welcomeCoordinator)
            } else if let uncompletedBackupCoordinator = coordinator.uncompletedBackupCoordinator {
                UncompletedBackupCoordinatorView(coordinator: uncompletedBackupCoordinator)
            } else if let authCoordinator = coordinator.authCoordinator {
                AuthCoordinatorView(coordinator: authCoordinator)
                    .if(coordinator.isMainScreenBottomSheetEnabled) { view in
                        view.animation(nil) // Fixes weird animations on appear when the view has a bottom scrollable sheet
                    }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(Colors.Text.primary1)
        .if(coordinator.isMainScreenBottomSheetEnabled) { view in
            // Unfortunately, we can't just apply the `bottomScrollableSheet` modifier here conditionally only when
            // `coordinator.manageTokensViewModel != nil` because this will break the root view's structural identity and
            // therefore all its state. Therefore `bottomScrollableSheet` view modifier is always applied,
            // but `header`/`content` views are created only when there is a non-nil `manageTokensViewModel`
            view.bottomScrollableSheet(
                isHiddenWhenCollapsed: true,
                allowsHitTesting: coordinator.manageTokensViewModel != nil,
                header: {
                    if let viewModel = coordinator.manageTokensViewModel {
                        ManageTokensBottomSheetHeaderContainerView(viewModel: viewModel)
                    }
                },
                content: {
                    if let viewModel = coordinator.manageTokensViewModel {
                        ManageTokensBottomSheetContentView(viewModel: viewModel)
                    }
                }
            )
        }
    }
}
