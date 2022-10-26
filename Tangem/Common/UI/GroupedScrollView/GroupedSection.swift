//
//  GroupedSection.swift
//  Tangem
//
//  Created by Sergey Balashov on 14.09.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct GroupedSection<Model: Identifiable, Content: View, Footer: View>: View {
    private let models: [Model]
    private let content: (Model) -> Content
    private let footer: () -> Footer

    @State private var contentVerticalPadding: CGFloat = 12
    @State private var separatorOffset: CGFloat = 16
    @State private var contentOffset: CGFloat = 16
    @State private var separatorStyle: SeparatorStyle = .single

    init(
        _ models: [Model],
        @ViewBuilder content: @escaping (Model) -> Content,
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) {
        self.models = models
        self.content = content
        self.footer = footer
    }

    init(
        _ model: Model,
        @ViewBuilder content: @escaping (Model) -> Content,
        @ViewBuilder footer: @escaping () -> Footer = { EmptyView() }
    ) {
        self.models = [model]
        self.content = content
        self.footer = footer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(models) { model in
                    content(model)
                        .padding(.horizontal, contentOffset)

                    if models.last?.id != model.id {
                        separator
                    }
                }
            }
            .padding(.vertical, contentVerticalPadding)
            .background(Colors.Background.primary)
            .cornerRadius(12)

            footer()
                .padding(.horizontal, contentOffset)
        }
        .padding(.vertical, 12)
    }

    @ViewBuilder private var separator: some View {
        switch separatorStyle {
        case .none:
            EmptyView()
        case .single:
            Colors.Stroke.primary
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(.leading, separatorOffset)
        }
    }
}

extension GroupedSection: Buildable {
    func contentVerticalPadding(_ padding: CGFloat) -> Self {
        map { $0.contentVerticalPadding = padding }
    }
}

enum SeparatorStyle: Int, Hashable {
    case none
    case single
}
