//
//  ExpressCoordinatorView.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct ExpressCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: ExpressCoordinator

    init(coordinator: ExpressCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationView {
            ZStack {
                if let rootViewModel = coordinator.rootViewModel {
                    ExpressView(viewModel: rootViewModel)
                }
                sheets
            }
        }
    }

    @ViewBuilder
    private var sheets: some View {
        NavHolder()
            .iOS16UIKitSheet(item: $coordinator.expressTokensListViewModel) {
                ExpressTokensListView(viewModel: $0)
            }
            .bottomSheet(
                item: $coordinator.expressApproveViewModel,
                settings: .init(backgroundColor: Colors.Background.tertiary)
            ) {
                ExpressApproveView(viewModel: $0)
            }
            .bottomSheet(
                item: $coordinator.expressFeeSelectorViewModel,
                settings: .init(backgroundColor: Colors.Background.tertiary)
            ) {
                ExpressFeeSelectorView(viewModel: $0)
            }
            .bottomSheet(
                item: $coordinator.expressProvidersSelectorViewModel,
                settings: .init(backgroundColor: Colors.Background.tertiary)
            ) {
                ExpressProvidersSelectorView(viewModel: $0)
            }

        NavHolder()
            .sheet(item: $coordinator.swappingSuccessCoordinator) {
                SwappingSuccessCoordinatorView(coordinator: $0)
            }
    }
}
