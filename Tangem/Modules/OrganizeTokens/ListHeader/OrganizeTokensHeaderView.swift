//
//  OrganizeTokensHeaderView.swift
//  Tangem
//
//  Created by m3g0byt3 on 06.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct OrganizeTokensHeaderView: View {
    @ObservedObject var viewModel: OrganizeTokensHeaderViewModel

    var body: some View {
        HStack(spacing: 8.0) {
            Group {
                if viewModel.isLeadingButtonSelected {
                    FlexySizeSelectedButtonWithLeadingIcon(
                        title: viewModel.leadingButtonTitle,
                        icon: Assets.OrganizeTokens.byBalanceSortIcon.image,
                        action: viewModel.onLeadingButtonTap
                    )
                } else {
                    FlexySizeDeselectedButtonWithLeadingIcon(
                        title: viewModel.leadingButtonTitle,
                        icon: Assets.OrganizeTokens.byBalanceSortIcon.image,
                        action: viewModel.onLeadingButtonTap
                    )
                }

                FlexySizeSelectedButtonWithLeadingIcon(
                    title: viewModel.trailingButtonTitle,
                    icon: Assets.OrganizeTokens.makeGroupIcon.image,
                    action: viewModel.onTrailingButtonTap
                )
            }
            .background(
                Colors.Background
                    .primary
                    .cornerRadiusContinuous(10.0)
            )
        }
    }
}

// MARK: - Previews

struct OrganizeTokensHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        OrganizeTokensHeaderView(
            viewModel: .init()
        )
    }
}
