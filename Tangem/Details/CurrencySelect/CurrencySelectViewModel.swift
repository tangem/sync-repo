//
//  CurrencySelectViewModel.swift
//  Tangem
//
//  Created by Alexander Osokin on 09.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class CurrencySelectViewModel: ViewModel, ObservableObject {
    @Injected(\.ratesServiceProvider) private var ratesServiceProvider: CurrencyRateServiceProviding
    
    @Published var loading: Bool = false
    @Published var currencies: [CurrenciesResponse.Currency] = []
    @Published var error: AlertBinder?
    
    private var bag = Set<AnyCancellable>()
    
    func onAppear() {
        loading = true
        ratesServiceProvider.ratesService
            .baseCurrencies()
            .receive(on: DispatchQueue.main)
            .mapError { _ in
                AppError.serverUnavailable
            }
            .sink(receiveCompletion: {[weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error.alertBinder
                }
                self?.loading = false
            }, receiveValue: {[weak self] currencies in
                self?.currencies = currencies
                    .sorted {
                        $0.description < $1.description
                    }
            })
            .store(in: &self.bag)
    }
}
