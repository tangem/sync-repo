//
//  ManageTokensBottomSheetHeaderView.swift
//  Tangem
//
//  Created by Andrey Fedorov on 20.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

#if ALPHA_OR_BETA
@available(*, deprecated, message: "Test only, remove if not needed")
struct ManageTokensBottomSheetHeaderView: View {
    @Binding private var searchText: String
    @State private var safeAreaBottomInset: CGFloat = .zero

    init(
        searchText: Binding<String>
    ) {
        _searchText = searchText
    }

    var body: some View {
        let additionalBottomInset = max(0.0, safeAreaBottomInset - Constants.verticalInset)

        TextField(Localization.commonSearch, text: $searchText)
            .readGeometry(\.safeAreaInsets.bottom) { [oldValue = safeAreaBottomInset] bottomInset in
                if oldValue != bottomInset {
                    // `DispatchQueue.main.async` used here to allow publishing changes during view update
                    DispatchQueue.main.async { safeAreaBottomInset = bottomInset }
                }
            }
            .frame(height: 46.0)
            .padding(.horizontal, 12.0)
            .background(Colors.Field.primary)
            .cornerRadius(14.0)
            .padding(.horizontal, 16.0)
            .padding(.vertical, Constants.verticalInset)
            .padding(.bottom, additionalBottomInset)
            .background(Colors.Background.primary)
    }
}

// MARK: - Constants

private extension ManageTokensBottomSheetHeaderView {
    enum Constants {
        static let verticalInset = 20.0
    }
}
#endif // ALPHA_OR_BETA
