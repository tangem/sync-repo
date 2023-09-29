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
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(Colors.Text.primary1)
        .bottomScrollableSheet(
            prefersGrabberVisible: coordinator.manageTokensSheetViewModel != nil,
            header: {
                if coordinator.manageTokensSheetViewModel != nil {
                    ManageTokensBottomSheetHeaderView(searchText: .constant(""))
                } else {
                    // Unfortunately, we can't just apply the `bottomScrollableSheet` modifier here conditionally only
                    // when needed because this will break the root view's structural identity and therefore all its state.
                    // So dummy views (`Color.clear`) are used as `header`/`content` views
                    Color.clear.frame(height: 100.0)
                }
            },
            content: {
                EmptyView() // TODO: Andrey Fedorov - Check and fix if needed lazy loading of content view
            }
        )
    }
}
