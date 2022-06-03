//
//  TotalSumBalanceViewModel.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 16.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine

class TotalSumBalanceViewModel: ObservableObject {
    @Injected(\.currencyRateService) private var currencyRateService: CurrencyRateService
    
    @Published var isLoading: Bool = false
    @Published var currencyType: String = ""
    @Published var totalFiatValueString: NSAttributedString = NSAttributedString(string: "")
    @Published var error: TotalBalanceError = .none
    
    private var bag = Set<AnyCancellable>()
    private var tokenItemViewModels: [TokenItemViewModel] = []
    
    init() {
        currencyType = currencyRateService.selectedCurrencyCode
    }
    
    func beginUpdates() {
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = .none
        }
    }
    
    func update(with tokens: [TokenItemViewModel]) {
        tokenItemViewModels = tokens
        refresh()
    }
    
    func updateIfNeeded(with tokens: [TokenItemViewModel]) {
        if tokenItemViewModels == tokens || isLoading {
            return
        }
        tokenItemViewModels = tokens
        refresh(loadingAnimationEnable: false)
    }
    
    func disableLoading(withError: TotalBalanceError = .none) {
        withAnimation(Animation.spring().delay(0.5)) {
            self.error = withError
            self.isLoading = false
        }
    }
    
    private func refresh(loadingAnimationEnable: Bool = true) {
        error = .none
        currencyType = currencyRateService.selectedCurrencyCode
        currencyRateService
            .baseCurrencies()
            .receive(on: RunLoop.main)
            .sink { _ in
            } receiveValue: { [weak self] currencies in
                guard let self = self,
                        let currency = currencies.first(where: { $0.code == self.currencyRateService.selectedCurrencyCode })
                else {
                    return
                }
                var hasError: TotalBalanceError = .none
                var totalFiatValue: Decimal = 0.0
                for token in self.tokenItemViewModels {
                    if token.state.isSuccesfullyLoaded {
                        if token.rate.isEmpty && !token.isCustom && !token.state.isNoAccount {
                            hasError = .imposibleCalculateAmount
                            break
                        }
                        totalFiatValue += token.fiatValue
                    } else {
                        hasError = .someNetworkUnreachable
                        break
                    }
                }
                
                switch hasError {
                case .none:
                    self.totalFiatValueString = self.addAttributeForBalance(totalFiatValue, withCurrencyCode: currency.code)
                case .someNetworkUnreachable, .imposibleCalculateAmount:
                    self.totalFiatValueString = NSMutableAttributedString(string: "—")
                }
                
                if loadingAnimationEnable {
                    self.disableLoading(withError: hasError)
                } else {
                    self.error = hasError
                }
            }.store(in: &bag)
    }
    
    private func addAttributeForBalance(_ balance: Decimal, withCurrencyCode: String) -> NSAttributedString {
        let formattedTotalFiatValue = balance.currencyFormatted(code: withCurrencyCode)
        
        let attributedString = NSMutableAttributedString(string: formattedTotalFiatValue)
        let allStringRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 28, weight: .semibold), range: allStringRange)
        
        let decimalLocation = NSString(string: formattedTotalFiatValue).range(of: balance.decimalSeparator()).location + 1
        let symbolsAfterDecimal = formattedTotalFiatValue.count - decimalLocation
        let rangeAfterDecimal = NSRange(location: decimalLocation, length: symbolsAfterDecimal)
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 20, weight: .semibold), range: rangeAfterDecimal)
        return attributedString
    }
}

extension TotalSumBalanceViewModel {
    enum TotalBalanceError {
        case none
        case imposibleCalculateAmount
        case someNetworkUnreachable
    }
}
