//
//  SendSummaryView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct SendSummaryView: View {
    let namespace: Namespace.ID

    @ObservedObject var viewModel: SendSummaryViewModel

    let bottomSpacing: CGFloat

    private let spacing: CGFloat = 14

    var body: some View {
        VStack(spacing: 14) {
            GroupedScrollView(spacing: 0) {
                if !viewModel.animatingDestinationOnAppear {
                    GroupedSection(viewModel.destinationSummaryViewData) { data in
                        SendDestinationAddressSummaryView(address: data.address)
                            .setNamespace(namespace)
                    }
                    .backgroundColor(viewModel.destinationBackground, id: SendViewNamespaceId.addressContainer.rawValue, namespace: namespace)
                    .contentShape(Rectangle())
                    .allowsHitTesting(viewModel.canEditDestination)
                    .onTapGesture {
                        viewModel.didTapSummary(for: .destination)
                    }
                }

                FixedSpacer(height: spacing)

                if !viewModel.animatingAmountOnAppear {
                    GroupedSection(viewModel.amountSummaryViewData) { data in
                        amountSectionContent(data: data)
                    }
                    .innerContentPadding(0)
                    .backgroundColor(viewModel.amountBackground, id: SendViewNamespaceId.amountContainer.rawValue, namespace: namespace)
                    .contentShape(Rectangle())
                    .allowsHitTesting(viewModel.canEditAmount)
                    .onTapGesture {
                        viewModel.didTapSummary(for: .amount)
                    }
                }

                FixedSpacer(height: spacing)

                if !viewModel.animatingFeeOnAppear {
                    GroupedSection(viewModel.selectedFeeSummaryViewModel) { data in
                        feeSectionContent(data: data)
                            .overlay {
                                ForEach(viewModel.deselectedFeeRowViewModels) { model in
                                    FeeRowView(viewModel: model)
                                        .setNamespace(namespace)
                                        .setOptionNamespaceId(SendViewNamespaceId.feeOption(feeOption: model.option).rawValue)
                                        .setAmountNamespaceId(SendViewNamespaceId.feeAmount(feeOption: model.option).rawValue)
                                        .allowsHitTesting(false)
                                        .opacity(0)
                                }
                            }
                    }
                    .backgroundColor(Colors.Background.action, id: SendViewNamespaceId.feeContainer.rawValue, namespace: namespace)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.didTapSummary(for: .fee)
                    }
                }

                if viewModel.showHint {
                    HintView(
                        text: Localization.sendSummaryTapHint,
                        font: Fonts.Regular.footnote,
                        textColor: Colors.Text.secondary,
                        backgroundColor: Colors.Button.secondary
                    )
                    .padding(.top, 8)
                    .transition(SendView.Constants.hintViewTransition)
                }

                ForEach(viewModel.notificationInputs) { input in
                    NotificationView(input: input)
                        .padding(.top, spacing)
                        .transition(SendView.Constants.auxiliaryViewTransition)
                }
            }

            if let transactionDescription = viewModel.transactionDescription,
               viewModel.showTransactionDescription {
                Text(transactionDescription)
                    .style(Fonts.Regular.caption1, color: Colors.Text.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .transition(.opacity)
                    .padding(.bottom, bottomSpacing + 14)
            }
        }
        .background(Colors.Background.tertiary.edgesIgnoringSafeArea(.all))
        .alert(item: $viewModel.alert) { $0.alert }
        .onAppear(perform: viewModel.onAppear)
        .interactiveDismissDisabled(viewModel.isSending)
    }

    private func amountSectionContent(data: SendAmountSummaryViewData) -> some View {
        SendAmountSummaryView(data: data)
            .setNamespace(namespace)
            .setIconNamespaceId(SendViewNamespaceId.tokenIcon.rawValue)
            .setAmountCryptoNamespaceId(SendViewNamespaceId.amountCryptoText.rawValue)
            .setAmountFiatNamespaceId(SendViewNamespaceId.amountFiatText.rawValue)
            .overlay(alignment: .top) {
                SendWalletInfoView(namespace: namespace, walletName: viewModel.walletName, walletBalance: viewModel.balance)
                    .opacity(0)
            }
    }

    private func feeSectionContent(data: SendFeeSummaryViewModel) -> some View {
        SendFeeSummaryView(data: data)
            .setNamespace(namespace)
            .setTitleNamespaceId(SendViewNamespaceId.feeTitle.rawValue)
            .setOptionNamespaceId(SendViewNamespaceId.feeOption(feeOption: data.feeOption).rawValue)
            .setAmountNamespaceId(SendViewNamespaceId.feeAmount(feeOption: data.feeOption).rawValue)
    }
}

struct SendSummaryView_Previews: PreviewProvider {
    @Namespace static var namespace

    static let tokenIconInfo = TokenIconInfo(
        name: "Tether",
        blockchainIconName: "ethereum.fill",
        imageURL: IconURLBuilder().tokenIconURL(id: "tether"),
        isCustom: false,
        customTokenColor: nil
    )

    static let walletInfo = SendWalletInfo(
        walletName: "Family Wallet",
        balanceValue: 2130.88,
        balance: "2 130,88 USDT (2 129,92 $)",
        blockchain: .ethereum(testnet: false),
        currencyId: "tether",
        feeCurrencySymbol: "ETH",
        feeCurrencyId: "ethereum",
        isFeeApproximate: false,
        tokenIconInfo: tokenIconInfo,
        cryptoIconURL: nil,
        cryptoCurrencyCode: "USDT",
        fiatIconURL: nil,
        fiatCurrencyCode: "USD",
        amountFractionDigits: 6,
        feeFractionDigits: 6,
        feeAmountType: .coin,
        canUseFiatCalculation: true
    )

    static let viewModel = SendSummaryViewModel(
        input: SendSummaryViewModelInputMock(),
        notificationManager: FakeSendNotificationManager(),
        fiatCryptoValueProvider: SendFiatCryptoValueProviderMock(),
        walletInfo: walletInfo
    )

    static var previews: some View {
        SendSummaryView(namespace: namespace, viewModel: viewModel, bottomSpacing: 0)
    }
}
