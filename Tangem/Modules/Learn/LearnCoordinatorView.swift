//
//  LearnCoordinatorView.swift
//
//
//  Created by Andrey Chukavin on 30.05.2023.
//

import SwiftUI

struct LearnCoordinatorView: CoordinatorView {
    @ObservedObject var coordinator: LearnCoordinator

    init(coordinator: LearnCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        ZStack {
            if let rootViewModel = coordinator.rootViewModel {
                LearnView(viewModel: rootViewModel)
                    .navigationLinks(links)
            }

            sheets
        }
    }

    @ViewBuilder
    private var links: some View {
        EmptyView()
    }

    @ViewBuilder
    private var sheets: some View {
        EmptyView()
    }
}
