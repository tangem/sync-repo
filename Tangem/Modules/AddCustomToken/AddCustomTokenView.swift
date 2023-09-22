//
//  AddCustomTokenView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 22.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct AddCustomTokenView: View {
    @ObservedObject private var viewModel: AddCustomTokenViewModel

    init(viewModel: AddCustomTokenViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Text("Hello, World!")
        }
    }
}

struct AddCustomTokenView_Preview: PreviewProvider {
    static let viewModel = AddCustomTokenViewModel(coordinator: AddCustomTokenCoordinator())

    static var previews: some View {
        AddCustomTokenView(viewModel: viewModel)
    }
}
