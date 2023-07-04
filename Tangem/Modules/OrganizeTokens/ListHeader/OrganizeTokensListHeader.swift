//
//  OrganizeTokensListHeader.swift
//  Tangem
//
//  Created by Andrey Fedorov on 21.06.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct OrganizeTokensListHeader: View {
    let viewModel: OrganizeTokensHeaderViewModel
    let scrollViewTopContentInset: Binding<CGFloat>
    let contentHorizontalInset: CGFloat
    let overlayViewAdditionalVerticalInset: CGFloat

    var body: some View {
        OrganizeTokensHeaderView(viewModel: viewModel)
            .readGeometry(\.size.height) { height in
                scrollViewTopContentInset.wrappedValue = height
                    + overlayViewAdditionalVerticalInset
                    + Constants.topInset
            }
            .padding(.top, Constants.topInset)
            .padding(.bottom, overlayViewAdditionalVerticalInset)
            .padding(.horizontal, contentHorizontalInset)
    }
}

// MARK: - Constants

private extension OrganizeTokensListHeader {
    private enum Constants {
        static let topInset = 4.0
    }
}
