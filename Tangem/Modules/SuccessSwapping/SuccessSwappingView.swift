//
//  SuccessSwappingView.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct SuccessSwappingView: View {
    @ObservedObject private var viewModel: SuccessSwappingViewModel

    init(viewModel: SuccessSwappingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    Color.clear.frame(height: geometry.size.height * 0.1)

                    VStack(spacing: geometry.size.height * 0.2) {
                        Assets.successWaiting.image

                        infoView
                    }
                }

                buttonView
            }
            .navigationBarTitle(Text(Localization.swappingSwap), displayMode: .inline)
        }
    }

    private var infoView: some View {
        VStack(spacing: 14) {
            Text(Localization.swappingSuccessViewTitle)
                .style(Fonts.Bold.title1, color: Colors.Text.primary1)

            VStack(spacing: 0) {
                Text(Localization.swappingSwapOfTo(viewModel.sourceFormatted))
                    .style(Fonts.Regular.callout, color: Colors.Text.secondary)

                Text(viewModel.resultFormatted)
                    .style(Fonts.Bold.callout, color: Colors.Text.accent)
            }
        }
    }

    private var buttonView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                if viewModel.isViewInExplorerAvailable {
                    MainButton(
                        title: Localization.swappingSuccessViewExplorerButtonTitle,
                        icon: .leading(Assets.arrowRightUpMini),
                        style: .secondary,
                        action: viewModel.didTapViewInExplorer
                    )
                }

                MainButton(
                    title: Localization.commonDone,
                    action: viewModel.didTapClose
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

struct SuccessSwappingView_Preview: PreviewProvider {
    static let viewModel = SuccessSwappingViewModel(
        inputModel: SuccessSwappingInputModel(
            sourceCurrencyAmount: .init(value: 1000, currency: .mock),
            resultCurrencyAmount: .init(value: 200, currency: .mock),
            explorerURL: URL(string: "")
        ),
        coordinator: SuccessSwappingCoordinator()
    )

    static var previews: some View {
        NavHolder()
            .sheet(isPresented: .constant(true)) {
                SuccessSwappingView(viewModel: viewModel)
            }
    }
}
