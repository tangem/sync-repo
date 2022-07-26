//
//  AppSettingsView.swift
//  Tangem
//
//  Created by Sergey Balashov on 26.07.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct AppSettingsView: View {
    @ObservedObject private var viewModel: AppSettingsViewModel

    init(viewModel: AppSettingsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            savingWalletSection

            savingAccessCodesSection
        }
        .listStyle(DefaultListStyle())
        .alert(item: $viewModel.alert) { $0.alert }
        .background(Colors.Background.secondary.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("app_settings_title", displayMode: .inline)
    }

    private var savingWalletSection: some View {
        Section(content: {
            DefaultToggleRowView(
                title: "app_settings_saved_wallet".localized,
                isOn: $viewModel.isSavingWallet
            )
        }, footer: {
            DefaultFooterView(title: "app_settings_saved_wallet_footer".localized)
        })
    }

    private var savingAccessCodesSection: some View {
        Section(content: {
            DefaultToggleRowView(
                title: "app_settings_saved_access_codes".localized,
                isOn: $viewModel.isSavingAccessCodes
            )
        }, footer: {
            DefaultFooterView(title: "app_settings_saved_access_codes_footer".localized)
        })
    }
}
