//
//  SendAmountViewModel.swift
//  Send
//
//  Created by Andrey Chukavin on 30.10.2023.
//

import Foundation
import SwiftUI
import Combine

protocol SendAmountViewModelInput {
    var amountTextBinding: Binding<String> { get }
    var amountError: AnyPublisher<Error?, Never> { get }
}

class SendAmountViewModel: ObservableObject {
    var amountText: Binding<String>

    @Published var amountError: String?

    init(input: SendAmountViewModelInput) {
        amountText = input.amountTextBinding

        input
            .amountError
            .map { $0?.localizedDescription }
            .assign(to: &$amountError) // weak
    }
}
