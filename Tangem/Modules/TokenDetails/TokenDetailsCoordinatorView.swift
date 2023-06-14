//
//  TokenDetailsCoordinatorView.swift
//  Tangem
//
//  Created by Andrew Son on 09/06/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct TokenDetailsCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: TokenDetailsCoordinator

    init(coordinator: TokenDetailsCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if let viewModel = coordinator.tokenDetailsViewModel {
                TokenDetailsView(viewModel: viewModel)
                    .navigationLinks(links)
            }

            sheets
        }
    }

    @ViewBuilder
    private var links: some View {
        NavHolder()
            .navigation(item: $coordinator.swappingCoordinator) {
                SwappingCoordinatorView(coordinator: $0)
            }
            .navigation(item: $coordinator.pushedWebViewModel) {
                WebViewContainer(viewModel: $0)
            }
    }

    @ViewBuilder
    private var sheets: some View {
        NavHolder()
            .sheet(item: $coordinator.sendCoordinator) {
                SendCoordinatorView(coordinator: $0)
            }
    }
}
