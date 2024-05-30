//
//  TOSStepView.swift
//  Tangem
//
//  Created by Alexander Osokin on 30.05.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

struct TOSStepView: View {
    @ObservedObject var viewModel: TOSStepViewModel

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    TOSStepView(viewModel: .init(routable: WelcomeOnboardingStepRoutableStub()))
}
