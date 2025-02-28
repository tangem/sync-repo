//
//  StoriesHostView.swift
//  TangemApp
//
//  Created by Aleksei Lobankov on 30.01.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import SwiftUI
import TangemFoundation

// TODO: @alobankov, move to TangemUI once resources generation moved to TangemUI
struct StoriesHostView: View {
    @ObservedObject var viewModel: StoriesHostViewModel
    let storyViews: [StoryView]

    init(viewModel: StoriesHostViewModel, storyViews: [StoryView]) {
        self.viewModel = viewModel
        self.storyViews = storyViews
    }

    var body: some View {
        TabView(selection: $viewModel.visibleStoryIndex) {
            ForEach(storyViews.indexed(), id: \.0) { index, storyView in
                ZStack(alignment: .top) {
                    storyView
                        .tag(index)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.default, value: viewModel.visibleStoryIndex)
        .allowsHitTesting(viewModel.allowsHitTesting)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
