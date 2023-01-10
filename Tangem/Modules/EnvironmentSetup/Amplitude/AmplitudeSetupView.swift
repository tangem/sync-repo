//
//  AmplitudeSetupView.swift
//  Tangem
//
//  Created by Andrew Son on 10/01/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI
import AlertToast

struct AmplitudeSetupView<ViewModel: AmplitudeSetupModelProtocol>: View  {
    @ObservedObject var viewModel: ViewModel
    var body: some View {
        VStack {
            DefaultToggleRowView(viewModel: DefaultToggleRowViewModel(title: "Is debug enabled", isOn: $viewModel.isOn))

            if viewModel.isOn {
                TextInputField(placeholder: "User id",
                               text: $viewModel.userId,
                               clearButtonMode: .whileEditing,
                               message: "This id will be displayed in Amplitude \"User Look-up\" section",
                               isErrorMessage: false)
                HStack {
                    Button(action: viewModel.updateUserId) {
                        Text("Apply userId")
                    }
                    .buttonStyle(TangemButtonStyle())

                    Button(action: viewModel.sendGatheredEvents, label: {
                        Text("Send events")
                    })
                    .buttonStyle(TangemButtonStyle())
                }
            }
        }
        .padding(.bottom, 8)
        .toast(isPresenting: $viewModel.isToastPresenting) {
            AlertToast(type: .complete(Color.tangemGreen),
                       title: viewModel.toastMessage)
        }
    }
}

struct AmplitudeSetupView_Previews: PreviewProvider {
    static var previews: some View {
        AmplitudeSetupView(viewModel: AmplitudeSetupViewModelMock())
    }
}
