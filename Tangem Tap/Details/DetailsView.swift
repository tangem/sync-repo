//
//  DetailsView.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 31.08.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import TangemSdk

struct DetailsRowView: View {
    var title: String
    var subtitle: String
    var body: some View {
        HStack (alignment: .center) {
            Text(title)
                .font(Font.system(size: 16.0, weight: .regular, design: .default))
                .foregroundColor(.tangemTapGrayDark6)
                .padding()
            Spacer()
            Text(subtitle)
                .font(Font.system(size: 16.0, weight: .regular, design: .default))
                .foregroundColor(.tangemTapGrayDark)
                .padding()
        }
        .listRowInsets(EdgeInsets())
    }
}

struct HeaderView: View {
    var text: String
    var body: some View {
        HStack {
            Text(text)
                .font(.headline)
                .foregroundColor(.tangemTapBlue)
                .padding()
            Spacer()
        }
        .padding(.top, 24.0)
        .background(Color.tangemTapBgGray)
        .listRowInsets(EdgeInsets())
    }
}

struct FooterView: View {
    var text: String
    var body: some View {
        HStack {
            Text(text)
                .font(.footnote)
                .foregroundColor(.tangemTapGrayDark)
                .padding()
        }
        .background(Color.tangemTapBgGray)
        .listRowInsets(EdgeInsets())
    }
}

struct DetailsDestination: Identifiable {
    let id: Int
    let destination: AnyView
}

struct DetailsView: View {
    @ObservedObject var viewModel: DetailsViewModel
    @EnvironmentObject var navigation: NavigationCoordinator
    @State var selection: String? = nil //fix remain highlited bug on ios14
    
    var body: some View {
        List {
            Section(header: EmptyView().listRowInsets(EdgeInsets())) {
                DetailsRowView(title: "details_row_title_cid".localized,
                               subtitle: viewModel.cardCid)
                DetailsRowView(title: "details_row_title_issuer".localized,
                               subtitle: viewModel.cardModel.cardInfo.card.cardData?.issuerName ?? " ")
                if viewModel.cardModel.cardInfo.card.walletSignedHashes != nil, !viewModel.isTwinCard {
                    DetailsRowView(title: "details_row_title_signed_hashes".localized,
                                   subtitle: String(format: "details_row_subtitle_signed_hashes_format".localized,
                                                    viewModel.cardModel.cardInfo.card.walletSignedHashes!.description))
                }
            }
            
            Section(header: HeaderView(text: "details_section_title_settings".localized)) {
                NavigationLink(destination: CurrencySelectView(viewModel: viewModel.assembly.makeCurrencySelectViewModel()),
                               tag: "currency", selection: $selection) {
                    DetailsRowView(title: "details_row_title_currency".localized,
                                   subtitle: viewModel.ratesService.selectedCurrencyCode)
                    
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                
                NavigationLink(destination: DisclaimerView(viewModel: viewModel.assembly.makeDisclaimerViewModel(with: .read))
                                .background(Color.tangemTapBgGray.edgesIgnoringSafeArea(.all)),
                               tag: "disclaimer", selection: $selection) {
                    DetailsRowView(title: "disclaimer_title".localized,
                                   subtitle: "")
                    
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
            }
            
            Section(header: HeaderView(text: "details_section_title_card".localized),
                    footer: !viewModel.isTwinCard && !viewModel.cardModel.canPurgeWallet ?
                        FooterView(text: "details_notification_erase_wallet_not_possible".localized).toAnyView()
                        : EmptyView().toAnyView()) {
                
                NavigationLink(destination: SecurityManagementView(viewModel:
                                                                    viewModel.assembly.makeSecurityManagementViewModel(with: viewModel.cardModel)),
                               tag: "secManagement", selection: $selection) {
                    DetailsRowView(title: "details_row_title_manage_security".localized,
                                   subtitle: viewModel.cardModel.currentSecOption.title)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                .disabled(!viewModel.cardModel.canManageSecurity)
                
                if viewModel.isTwinCard {
                    NavigationLink(destination: TwinCardOnboardingView(viewModel: viewModel.assembly.makeTwinCardWarningViewModel(isRecreating: true)),
                                   isActive: $navigation.detailsToTwinsRecreateWarning){
                        DetailsRowView(title: "details_row_title_twins_recreate".localized, subtitle: "")
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                    .disabled(!viewModel.cardModel.canRecreateTwinCard)
                    
                } else {
                    NavigationLink(destination: CardOperationView(title: "details_row_title_erase_wallet".localized,
                                                                  buttonTitle: "details_row_title_erase_wallet",
                                                                  alert: "details_erase_wallet_warning".localized,
                                                                  actionButtonPressed: {self.viewModel.cardModel.purgeWallet(completion: $0)}
                    ),
                    tag: "cardOp", selection: $selection) {
                        DetailsRowView(title: "details_row_title_erase_wallet".localized, subtitle: "")
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                    .disabled(!viewModel.cardModel.canPurgeWallet)
                }
            }
            
            Section(header: Color.tangemTapBgGray
                        .listRowInsets(EdgeInsets())) {
                EmptyView()
            }
        }
        .padding(.top, 16)
        .background(Color.tangemTapBgGray.edgesIgnoringSafeArea(.all))
        .navigationBarTitle("details_title", displayMode: .inline)
        .navigationBarBackButtonHidden(false)
        .navigationBarHidden(false)
        .onDisappear {
            if #available(iOS 14.3, *) {
                self.selection = nil
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(viewModel: Assembly.previewAssembly.makeDetailsViewModel(with: CardViewModel.previewCardViewModel))
            .environmentObject(Assembly.previewAssembly.navigationCoordinator)
    }
}
