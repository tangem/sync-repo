//
//  SendModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BlockchainSdk

class SendModel {
    var amountValid: AnyPublisher<Bool, Never> {
        amount
            .map {
                $0 != nil
            }
            .eraseToAnyPublisher()
    }

    var destinationValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(destination, destinationAdditionalFieldError)
            .map {
                $0 != nil && $1 == nil
            }
            .eraseToAnyPublisher()
    }

    var feeValid: AnyPublisher<Bool, Never> {
        .just(output: true)
    }

    var transactionFinished: AnyPublisher<Bool, Never> {
        _transactionTime
            .map {
                $0 != nil
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private(set) var isFiatCalculation: Bool = false

    // MARK: - Data

    private var amount = CurrentValueSubject<DecimalNumberTextField.DecimalValue?, Never>(nil)
    private let destination = CurrentValueSubject<String?, Never>(nil)
    private let destinationAdditionalField = CurrentValueSubject<String?, Never>(nil)
    private let fee = CurrentValueSubject<Fee?, Never>(nil)

    private let transaction = CurrentValueSubject<BlockchainSdk.Transaction?, Never>(nil)

    // MARK: - Raw data

    private var _amount: DecimalNumberTextField.DecimalValue?
    private var _destinationText: String = ""
    private var _destinationAdditionalFieldText: String = ""
    private var _feeText: String = ""

    private let _isSending = CurrentValueSubject<Bool, Never>(false)
    private let _transactionTime = CurrentValueSubject<Date?, Never>(nil)

    // MARK: - Errors (raw implementation)

    private let _amountError = CurrentValueSubject<Error?, Never>(nil)
    private let _destinationError = CurrentValueSubject<Error?, Never>(nil)
    private let _destinationAdditionalFieldError = CurrentValueSubject<Error?, Never>(nil)

    // MARK: - Private stuff

    private let walletModel: WalletModel
    private let transactionSigner: TransactionSigner
    private let sendType: SendType
    private var bag: Set<AnyCancellable> = []

    // MARK: - Public interface

    init(walletModel: WalletModel, transactionSigner: TransactionSigner, sendType: SendType) {
        self.walletModel = walletModel
        self.transactionSigner = transactionSigner
        self.sendType = sendType

        if let amount = sendType.predefinedAmount {
            #warning("TODO")
            setAmount(.external(amount))
        }

        if let destination = sendType.predefinedDestination {
            setDestination(destination)
        }

        validateAmount()
        validateDestination()
        validateDestinationAdditionalField()
        bind()
    }

    func setIsFiatCalculation(_ isFiatCalculation: Bool) {
        self.isFiatCalculation = isFiatCalculation

        #warning("TODO")
    }

    func useMaxAmount() {
        #warning("TODO")
    }

    func send() {
        guard var transaction = transaction.value else {
            return
        }

        #warning("TODO: memo")
        #warning("TODO: loading view")
        #warning("TODO: demo")

        _isSending.send(true)
        walletModel.send(transaction, signer: transactionSigner)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }

                _isSending.send(false)

                print("SEND FINISH ", completion)
                #warning("TODO: handle result")
            } receiveValue: { [weak self] result in
                guard let self else { return }

                _transactionTime.send(Date())
            }
            .store(in: &bag)
    }

    private func bind() {
        #warning("TODO: fee retry?")
        Publishers.CombineLatest(amount, destination)
            .flatMap { [weak self] amount, destination -> AnyPublisher<[Fee], Never> in
                guard
                    let self,
                    let amount,
                    let destination
                else {
                    return .just(output: [])
                }

                let blockchain = walletModel.blockchainNetwork.blockchain
                let amountToSend = Amount(with: blockchain, type: walletModel.amountType, value: amount.value)

                #warning("TODO: loading fees indicator")
                return walletModel
                    .getFee(amount: amountToSend, destination: destination)
                    .receive(on: DispatchQueue.main)
                    .catch { [weak self] error in
                        #warning("TODO: handle error")
                        return Just([Fee]())
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink { [weak self] fees in
                guard let self else { return }

                #warning("TODO: save fee options")
                fee.send(fees.first)

                print("fetched fees:", fees)
            }
            .store(in: &bag)

        Publishers.CombineLatest4(amount, destination, destinationAdditionalField, fee)
            .map { [weak self] amount, destination, destinationAdditionalField, fee -> BlockchainSdk.Transaction? in
                guard
                    let self,
                    let amount,
                    let destination,
                    let fee
                else {
                    return nil
                }

                let blockchain = walletModel.blockchainNetwork.blockchain
                let amountToSend = Amount(with: blockchain, type: walletModel.amountType, value: amount.value)

                #warning("TODO: Show error alert?")
                return try? walletModel.createTransaction(
                    amountToSend: amountToSend,
                    fee: fee,
                    destinationAddress: destination
                )
            }
            .sink { transaction in
                self.transaction.send(transaction)
                print("TX built", transaction != nil)
            }
            .store(in: &bag)
    }

    // MARK: - Amount

    private func setAmount(_ amount: DecimalNumberTextField.DecimalValue?) {
        _amount = amount
        validateAmount()
    }

    private func validateAmount() {
        let amount: DecimalNumberTextField.DecimalValue?
        let error: Error?

        #warning("validate")
        amount = _amount
        error = nil

        self.amount.send(amount)
        _amountError.send(error)
    }

    // MARK: - Destination and memo

    private func setDestination(_ destinationText: String) {
        _destinationText = destinationText
        validateDestination()
    }

    private func validateDestination() {
        let destination: String?
        let error: Error?

        #warning("validate")
        destination = _destinationText
        error = nil

        self.destination.send(destination)
        _destinationError.send(error)
    }

    private func setDestinationAdditionalField(_ destinationAdditionalFieldText: String) {
        _destinationAdditionalFieldText = destinationAdditionalFieldText
        validateDestinationAdditionalField()
    }

    private func validateDestinationAdditionalField() {
        let destinationAdditionalField: String?
        let error: Error?

        #warning("validate")
        destinationAdditionalField = _destinationAdditionalFieldText
        error = nil

        self.destinationAdditionalField.send(destinationAdditionalField)
        _destinationAdditionalFieldError.send(error)
    }

    // MARK: - Fees

    private func setFee(_ feeText: String) {
        #warning("set and validate")
        _feeText = feeText
    }
}

// MARK: - Subview model inputs

extension SendModel: SendAmountViewModelInput {
    #warning("TODO")
    var walletName: String {
        "My Wallet (TODO)"
    }

    #warning("TODO")
    var balance: String {
        "2 130,88 USDT (2 129,92 $)"
    }

    #warning("TODO")
    var tokenIconName: String {
        "tether"
    }

    #warning("TODO")
    var tokenIconURL: URL? {
        TokenIconURLBuilder().iconURL(id: "tether")
    }

    #warning("TODO")
    var tokenIconCustomTokenColor: Color? {
        nil
    }

    #warning("TODO")
    var tokenIconBlockchainIconName: String? {
        "ethereum.fill"
    }

    #warning("TODO")
    var isCustomToken: Bool {
        false
    }

    #warning("TODO")
    var amountFractionDigits: Int {
        2
    }

    #warning("TODO")
    var amountAlternativePublisher: AnyPublisher<String, Never> {
        .just(output: "1 000 010,99 USDT")
    }

    var decimalValue: Binding<DecimalNumberTextField.DecimalValue?> {
        Binding { self._amount } set: { self.setAmount($0) }
    }

    #warning("TODO")
    var errorPublisher: AnyPublisher<Error?, Never> {
        _amountError.eraseToAnyPublisher()
    }

    var amountError: AnyPublisher<Error?, Never> { _amountError.eraseToAnyPublisher() }

    #warning("TODO")
    var cryptoCurrencyCode: String {
        "USDT"
    }

    #warning("TODO")
    var fiatCurrencyCode: String {
        "USD"
    }
}

extension SendModel: SendDestinationViewModelInput {
    var destinationTextBinding: Binding<String> { Binding(get: { self._destinationText }, set: { self.setDestination($0) }) }
    var destinationAdditionalFieldTextBinding: Binding<String> { Binding(get: { self._destinationAdditionalFieldText }, set: { self.setDestinationAdditionalField($0) }) }
    var destinationError: AnyPublisher<Error?, Never> { _destinationError.eraseToAnyPublisher() }
    var destinationAdditionalFieldError: AnyPublisher<Error?, Never> { _destinationAdditionalFieldError.eraseToAnyPublisher() }
}

extension SendModel: SendFeeViewModelInput {
    var feeTextBinding: Binding<String> { Binding(get: { self._feeText }, set: { self.setFee($0) }) }
}

extension SendModel: SendSummaryViewModelInput {
    #warning("TODO")
    var amountText: String {
        "100"
    }

    var canEditAmount: Bool {
        sendType.predefinedAmount == nil
    }

    var canEditDestination: Bool {
        sendType.predefinedDestination == nil
    }

    var isSending: AnyPublisher<Bool, Never> {
        _isSending.eraseToAnyPublisher()
    }
}
