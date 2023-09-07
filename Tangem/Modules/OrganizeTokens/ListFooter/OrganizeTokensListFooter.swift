//
//  OrganizeTokensListFooter.swift
//  Tangem
//
//  Created by Andrey Fedorov on 21.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct OrganizeTokensListFooter: View {
    let viewModel: OrganizeTokensViewModel
    let isTokenListFooterGradientHidden: Bool
    let cornerRadius: CGFloat
    let horizontalInset: CGFloat

    @State private var hasBottomSafeAreaInset = false

    private let buttonSize: MainButton.Size = .default

    private var buttonsPadding: EdgeInsets {
        // Different padding on devices with/without notch
        let bottomPadding = hasBottomSafeAreaInset ? 6.0 : 12.0
        return EdgeInsets(top: 14.0, leading: horizontalInset, bottom: bottomPadding, trailing: horizontalInset)
    }

    private var overlayViewTopPadding: CGFloat {
        // 75pt is derived from mockups
        return -max(75.0 - buttonsPadding.top - buttonSize.height, 0.0)
    }

    var body: some View {
        HStack(spacing: 8.0) {
            Group {
                MainButton(
                    title: Localization.commonCancel,
                    style: .secondary,
                    size: buttonSize,
                    action: viewModel.onCancelButtonTap
                )

                MainButton(
                    title: Localization.commonApply,
                    style: .primary,
                    size: buttonSize,
                    action: viewModel.onApplyButtonTap
                )
            }
        }
        .padding(buttonsPadding)
        .readGeometry(\.safeAreaInsets.bottom) { [oldValue = hasBottomSafeAreaInset] bottomInset in
            let newValue = bottomInset != 0.0
            if newValue != oldValue {
                hasBottomSafeAreaInset = newValue
            }
        }
        .background(
            OrganizeTokensListFooterOverlayView()
                .padding(.top, overlayViewTopPadding)
                .hidden(isTokenListFooterGradientHidden)
        )
    }
}
