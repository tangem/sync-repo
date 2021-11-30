//
//  MainView.swift
//  TangemClip
//
//  Created by Andrew Son on 05/03/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI
import StoreKit

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    
    @State var isDisplayingAppStoreOverlay = false
    
    var body: some View {
        VStack {
            Text("main_title")
                .font(.system(size: 17, weight: .medium))
                .frame(height: 44, alignment: .center)
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 8) {
                        CardView(image: viewModel.image,
                                 width: geometry.size.width - 32)
                            .fixedSize(horizontal: false, vertical: true)
                        switch viewModel.state {
                        case .notScannedYet:
                            Spacer()
                            Text("main_warning")
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 2)
                            Spacer()
                        case .card(let cardModel):
                            if viewModel.isCardEmpty {
                                MessageView(title: "main_error_empty_card_title".localized, subtitle: "main_error_empty_card_subtitle".localized, type: .error)
                            } else {
                                if cardModel.loadingBalancesCounter == 0 && viewModel.tokenItemViewModels.isEmpty {
                                    MessageView(title: "main_error_empty_wallets_title".localized, subtitle: "main_error_empty_wallets_subtitle".localized, type: .message)
                                        .animation(.easeInOut)
                                } else {
                                    ForEach(viewModel.tokenItemViewModels) { item in
                                        TokensListItemView(item: item)
                                            .onTapGesture { }
                                    }
                                    .padding(.horizontal, 16)
                                    ActivityIndicatorView(isAnimating: cardModel.loadingBalancesCounter != 0, style: .medium, color: .tangemGrayDark6)
                                        .padding(.vertical, 10)
                                        .opacity(cardModel.loadingBalancesCounter > 0 ? 1 : 0)
                                        .animation(.easeInOut)
                                    Color.clear.frame(width: 100, height: viewModel.shouldShowGetFullApp ? 170 : 20, alignment: .center)
                                }
                            }
                        case .unsupported:
                            MessageView(title: "main_error_unsupported_card_title".localized, subtitle: "main_error_unsupported_card_subtitle".localized, type: .error)
                        }
                    }
                }
                .frame(width: geometry.size.width)
            }
            .appStoreOverlay(isPresented: .constant(true)) { () -> SKOverlay.Configuration in
                SKOverlay.AppClipConfiguration(position: .bottom)
            }
            
//            if viewModel.state == .notScannedYet {
//                TangemButton(title: "main_button_read_wallets",
//                             image: "scan",
//                             action: viewModel.scanCard)
//                    .buttonStyle(TangemButtonStyle(colorStyle: .black,
//                                                   layout: .big,
//                                                   isLoading: viewModel.isScanning))
//                .padding(.bottom, 48)
//            }
        }
        .background(Color.tangemBgGray.edgesIgnoringSafeArea(.all))
    }
    
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: Assembly.previewAssembly.getMainViewModel())
    }
}
