//
//  SendFiatCryptoHelper.swift
//  Tangem
//
//  Created by Andrey Chukavin on 19.01.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI
import Combine
import BlockchainSdk

class SendFiatCryptoHelper {
    var userInputAmount: AnyPublisher<Decimal?, Never> {
        _userInputAmount.eraseToAnyPublisher()
    }

    var modelAmount: AnyPublisher<Amount?, Never> {
        _fiatCryptoValue
            .crypto
            .map { [weak self] cryptoAmount in
                guard let self, let cryptoAmount else { return nil }

                return Amount(with: blockchain, type: amountType, value: cryptoAmount)
            }
            .eraseToAnyPublisher()
    }

    private let blockchain: Blockchain
    private let amountType: Amount.AmountType
    private let cryptoCurrencyId: String?
    private let amountFractionDigits: Int

    private var _userInputAmount = CurrentValueSubject<Decimal?, Never>(nil)
    private var _fiatCryptoValue = FiatCryptoValue(crypto: nil, fiat: nil)
    private var _useFiatCalculation = CurrentValueSubject<Bool, Never>(false)

    private var inputTrigger: InputTrigger = .keyboard

    private var bag: Set<AnyCancellable> = []

    init(
        blockchain: Blockchain,
        amountType: Amount.AmountType,
        cryptoCurrencyId: String?,
        amountFractionDigits: Int
    ) {
        self.blockchain = blockchain
        self.amountType = amountType
        self.cryptoCurrencyId = cryptoCurrencyId
        self.amountFractionDigits = amountFractionDigits

        bind()
    }

    func bind() {
        _userInputAmount
            .removeDuplicates()
            .sink { [weak self] decimal in
                guard let self else { return }

                guard inputTrigger == .keyboard else {
                    inputTrigger = .keyboard
                    return
                }

                let useFiatCalculation = _useFiatCalculation.value
                if let newAmountValue = fiatCryptoValue(from: decimal, useFiatCalculation: useFiatCalculation) {
                    _fiatCryptoValue.update(crypto: newAmountValue.crypto.value, fiat: newAmountValue.fiat)
                }
            }
            .store(in: &bag)
    }

    func didChooseMaxAmount() {
        inputTrigger = .maxAmount
    }

    func setUserInputAmount(_ amount: Decimal?) {
        _userInputAmount.send(amount)
    }

    func setModelAmount(_ amount: Decimal?) {
        guard let newAmountValue = fiatCryptoValue(from: amount, useFiatCalculation: false) else { return }

        _fiatCryptoValue.update(crypto: newAmountValue.crypto.value, fiat: newAmountValue.fiat)
        if inputTrigger != .keyboard {
            setTextFieldAmount(useFiatCalculation: _useFiatCalculation.value)
        }
    }

    func setUseFiatCalculation(_ useFiatCalculation: Bool) {
        guard _userInputAmount.value != nil else {
            return
        }

        inputTrigger = .currencySelector

        _useFiatCalculation.send(useFiatCalculation)
        setTextFieldAmount(useFiatCalculation: useFiatCalculation)
    }

    private func fiatCryptoValue(from amount: Decimal?, useFiatCalculation: Bool) -> FiatCryptoValue? {
        guard let amount else {
            return FiatCryptoValue(crypto: nil, fiat: nil)
        }

        let newCryptoAmount: Decimal?
        let newFiatAmount: Decimal?

        if let cryptoCurrencyId {
            let balanceConverter = BalanceConverter()
            if useFiatCalculation {
                newCryptoAmount = balanceConverter.convertFromFiat(value: amount, to: cryptoCurrencyId)?.rounded(scale: amountFractionDigits)
                newFiatAmount = amount
            } else {
                newCryptoAmount = amount
                newFiatAmount = balanceConverter.convertToFiat(value: amount, from: cryptoCurrencyId)?.rounded(scale: 2)
            }
        } else {
            newCryptoAmount = amount
            newFiatAmount = nil
        }

        let newValue = FiatCryptoValue(crypto: newCryptoAmount, fiat: newFiatAmount)
        guard newValue != _fiatCryptoValue else {
            return nil
        }

        return newValue
    }

    private func setTextFieldAmount(useFiatCalculation: Bool) {
        let newAmount = useFiatCalculation ? _fiatCryptoValue.fiat : _fiatCryptoValue.crypto.value
        _userInputAmount.send(newAmount)
    }
}

private extension SendFiatCryptoHelper {
    class FiatCryptoValue: Equatable {
        private(set) var crypto = CurrentValueSubject<Decimal?, Never>(nil)
        private(set) var fiat: Decimal?

        init(crypto: Decimal?, fiat: Decimal? = nil) {
            self.crypto.send(crypto)
            self.fiat = fiat
        }

        func update(crypto: Decimal?, fiat: Decimal?) {
            self.crypto.send(crypto)
            self.fiat = fiat
        }

        static func == (left: SendFiatCryptoHelper.FiatCryptoValue, right: SendFiatCryptoHelper.FiatCryptoValue) -> Bool {
            left.crypto.value == right.crypto.value && left.fiat == right.fiat
        }
    }
}

private extension SendFiatCryptoHelper {
    enum InputTrigger {
        case keyboard
        case currencySelector
        case maxAmount
    }
}

// TODO: add struct instead of tuple // container; setFiat; setCrypto
// TODO: func mutate() { crypto = ; fiat = }
