//
//  TokenSelectorView.swift
//  TangemApp
//
//  Created by GuitarKitty on 30.10.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine

struct TokenSelectorView<
    Builder: TokenSelectorItemBuilder,
    TokenModel: Identifiable & Equatable,
    ViewModel: TokenSelectorViewModel<TokenModel, Builder>,
    TokenCellContent: View,
    EmptySearchContent: View
>: View {
    @ObservedObject var viewModel: ViewModel

    private let tokenCellContent: (TokenModel) -> TokenCellContent
    private let emptySearchContent: EmptySearchContent

    init(
        viewModel: ViewModel,
        tokenCellContent: @escaping (TokenModel) -> TokenCellContent,
        emptySearchContent: () -> EmptySearchContent = { EmptyView() }
    ) {
        self.viewModel = viewModel
        self.tokenCellContent = tokenCellContent
        self.emptySearchContent = emptySearchContent()
    }

    var body: some View {
        ZStack(alignment: .top) {
            Colors.Background.tertiary.ignoresSafeArea(.all)

            content
                .animation(.default, value: viewModel.viewState)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .empty:
            emptyContent
        case .data(let availableTokens, let unavailableTokens):
            GroupedScrollView(alignment: .leading, spacing: 14) {
                availableSection(
                    title: viewModel.strings.availableTokensListTitle,
                    items: availableTokens
                )

                unavailableSection(
                    title: viewModel.strings.unavailableTokensListTitle,
                    items: unavailableTokens
                )
            }
        }
    }

    @ViewBuilder
    private var emptyContent: some View {
        if let emptyTokensMessage = viewModel.strings.emptyTokensMessage {
            VStack(spacing: .zero) {
                Spacer()

                VStack(spacing: 16) {
                    Assets.emptyTokenList.image
                        .renderingMode(.template)
                        .foregroundColor(Colors.Icon.inactive)

                    Text(emptyTokensMessage)
                        .multilineTextAlignment(.center)
                        .style(Fonts.Regular.footnote, color: Colors.Text.tertiary)
                        .padding(.horizontal, 50)
                }

                Spacer()
            }
        }
    }
}

// MARK: - Available section

private extension TokenSelectorView {
    @ViewBuilder
    func availableSection(title: String, items: [TokenModel]) -> some View {
        if viewModel.searchText.isNotEmpty || items.isNotEmpty {
            GroupedSection(
                items,
                content: { item in
                    tokenCellContent(item)
                },
                header: {
                    availableSectionHeader(title: title, itemsIsNotEmpty: items.isNotEmpty)
                        .padding(.init(top: 12, leading: 0, bottom: 8, trailing: 0))
                },
                emptyContent: {
                    emptySearchContent
                        .padding(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                }
            )
            .settings(\.backgroundColor, Colors.Background.action)
        }
    }

    func availableSectionHeader(title: String, itemsIsNotEmpty: Bool) -> some View {
        VStack(alignment: .leading, spacing: 26) {
            CustomSearchBar(
                searchText: $viewModel.searchText,
                placeholder: Localization.commonSearch,
                style: .focused
            )

            if itemsIsNotEmpty {
                DefaultHeaderView(title)
                    .transition(.opacity.animation(.default))
            }
        }
    }
}

// MARK: - Unavailable section

private extension TokenSelectorView {
    @ViewBuilder
    func unavailableSection(title: String, items: [TokenModel]) -> some View {
        if items.isNotEmpty {
            GroupedSection(
                items,
                content: { item in
                    tokenCellContent(item)
                },
                header: {
                    DefaultHeaderView(title)
                        .padding(.vertical, 12)
                }
            )
            .settings(\.backgroundColor, Colors.Background.action)
        }
    }
}
