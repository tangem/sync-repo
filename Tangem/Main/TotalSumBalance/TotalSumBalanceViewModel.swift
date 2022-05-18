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
    
    var tokens: Published<[TokenItemViewModel]>.Publisher
    @Published var isLoading: Bool = false
    @Published var currencyType: String = ""
    @Published var totalFiatValueString: String = "0,00"
    @Published var isFailed: Bool = false
    
    private var bag = Set<AnyCancellable>()
    private var tokenItems: [TokenItemViewModel] = []
    
    init(tokens: Published<[TokenItemViewModel]>.Publisher) {
        self.tokens = tokens
        currencyType = currencyRateService.selectedCurrencyCode
        bind()
    }
    
    func bind() {
        tokens
            .sink { [weak self] newValue in
            guard let tokenItem = self?.tokenItems else { return }
            if newValue == tokenItem && !tokenItem.isEmpty {
                return
            }
            self?.tokenItems = newValue
            DispatchQueue.main.async {
                self?.refresh()
            }
        }.store(in: &bag)
    }
    
    func refresh() {
        guard !isLoading
        else {
            return
        }
        isFailed = false
        isLoading = true
        currencyType = currencyRateService.selectedCurrencyCode
        currencyRateService
            .baseCurrencies()
            .receive(on: RunLoop.main)
            .sink { _ in
                
            } receiveValue: { currencies in
                guard let currency = currencies.first(where: { $0.code == self.currencyRateService.selectedCurrencyCode }) else { return }
                var totalFiatValue: Decimal = 0.0
                self.tokenItems.forEach { token in
                    if token.state.isSuccesfullyLoaded {
                        totalFiatValue += token.fiatValue
                    } else {
                        self.isFailed = true
                    }
                }
                
                self.totalFiatValueString = totalFiatValue.currencyFormatted(code: currency.code)
                
                self.disableLoading()
            }.store(in: &bag)
    }
    
    func disableLoading() {
        withAnimation(Animation.linear.delay(0.5)) {
            self.isLoading = false
        }
    }
    
}
