//
//  View+DescriptionBottomSheet.swift
//  Tangem
//
//  Created by Andrew Son on 16/07/24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func descriptionBottomSheet(
        info: Binding<DescriptionBottomSheetInfo?>,
        backgroundColor: Color?
    ) -> some View {
        sheet(item: info) { info in
            DescriptionBottomSheetView(info: info)
                .padding(.bottom, 10)
                .adaptivePresentationDetents()
                .background(backgroundColor.ignoresSafeArea(.all, edges: .bottom))
        }
    }

    @ViewBuilder
    func tokenDescriptionBottomSheet(
        info: Binding<DescriptionBottomSheetInfo?>,
        backgroundColor: Color?,
        onGeneratedAITapAction: (() -> Void)?
    ) -> some View {
        sheet(item: info) { info in
            TokenDescriptionBottomSheetView(info: info, generatedWithAIAction: onGeneratedAITapAction)
                .adaptivePresentationDetents()
                .padding(.bottom, 10)
                .background(backgroundColor.ignoresSafeArea(.all, edges: .bottom))
        }
    }
}
