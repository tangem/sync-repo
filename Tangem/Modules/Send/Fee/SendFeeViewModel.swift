//
//  SendFeeViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BlockchainSdk

protocol SendFeeViewModelInput {
    var amountPublisher: AnyPublisher<Amount?, Never> { get }
    var selectedFeeOption: FeeOption { get }
    var feeOptions: [FeeOption] { get }
    var feeValues: AnyPublisher<[FeeOption: LoadingValue<Fee>], Never> { get }

    var canIncludeFeeIntoAmount: Bool { get }
    var isFeeIncludedPublisher: AnyPublisher<Bool, Never> { get }

    func didSelectFeeOption(_ feeOption: FeeOption)
    func didChangeFeeInclusion(_ isFeeIncluded: Bool)
}

class SendFeeViewModel: ObservableObject {
    @Published private(set) var selectedFeeOption: FeeOption
    @Published private(set) var feeRowViewModels: [FeeRowViewModel] = []

    @Published private(set) var subtractFromAmountFooterText: String = ""
    @Published private(set) var subtractFromAmountModel: DefaultToggleRowViewModel?

    @Published private var isFeeIncluded: Bool = false

    private let input: SendFeeViewModelInput
    private let feeOptions: [FeeOption]
    private let walletInfo: SendWalletInfo
    private var bag: Set<AnyCancellable> = []

    private var feeFormatter: FeeFormatter {
        CommonFeeFormatter(
            balanceFormatter: BalanceFormatter(),
            balanceConverter: BalanceConverter()
        )
    }

    init(input: SendFeeViewModelInput, walletInfo: SendWalletInfo) {
        self.input = input
        self.walletInfo = walletInfo
        feeOptions = input.feeOptions
        selectedFeeOption = input.selectedFeeOption
        feeRowViewModels = makeFeeRowViewModels([:])

        let isFeeIncludedBinding = BindingValue<Bool>(root: self, default: isFeeIncluded) {
            $0.isFeeIncluded
        } set: {
            $0.isFeeIncluded = $1
            $0.input.didChangeFeeInclusion($1)
        }
        if input.canIncludeFeeIntoAmount {
            subtractFromAmountModel = DefaultToggleRowViewModel(title: Localization.sendAmountSubstract, isDisabled: false, isOn: isFeeIncludedBinding)
        }

        bind()
    }

    private func bind() {
        input.feeValues
            .sink { [weak self] feeValues in
                guard let self else { return }
                feeRowViewModels = makeFeeRowViewModels(feeValues)
            }
            .store(in: &bag)

        input.isFeeIncludedPublisher
            .sink { [weak self] feeIncluded in
                self?.isFeeIncluded = feeIncluded
            }
            .store(in: &bag)

        input.amountPublisher
            .map {
                if let amountFormatted = $0?.string() {
                    return Localization.sendAmountSubstractFooter(amountFormatted)
                } else {
                    return ""
                }
            }
            .assign(to: \.subtractFromAmountFooterText, on: self, ownership: .weak)
            .store(in: &bag)
    }

    private func makeFeeRowViewModels(_ feeValues: [FeeOption: LoadingValue<Fee>]) -> [FeeRowViewModel] {
        let formattedFeeValues: [FeeOption: LoadingValue<String>] = feeValues.mapValues { fee in
            switch fee {
            case .loading:
                return .loading
            case .loaded(let value):
                let formattedValue = self.feeFormatter.format(
                    fee: value.amount.value,
                    currencySymbol: walletInfo.feeCurrencySymbol,
                    currencyId: walletInfo.feeCurrencyId,
                    isFeeApproximate: walletInfo.isFeeApproximate
                )
                return .loaded(formattedValue)
            case .failedToLoad(let error):
                return .failedToLoad(error: error)
            }
        }

        return feeOptions.map { option in
            let value = formattedFeeValues[option] ?? .loading

            return FeeRowViewModel(
                option: option,
                subtitle: value,
                isSelected: .init(root: self, default: false, get: { root in
                    root.selectedFeeOption == option
                }, set: { root, newValue in
                    if newValue {
                        root.selectedFeeOption = option
                        root.input.didSelectFeeOption(option)
                    }
                })
            )
        }
    }
}
