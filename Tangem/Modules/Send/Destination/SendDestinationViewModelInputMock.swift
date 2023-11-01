//
//  SendDestinationViewModelInputMock.swift
//  Send
//
//  Created by Andrey Chukavin on 01.11.2023.
//

import SwiftUI
import Combine

class SendDestinationViewModelInputMock: SendDestinationViewModelInput {
    var destinationTextBinding: Binding<String> {
        .constant("0x123123")
    }

    var destinationAdditionalFieldTextBinding: Binding<String> {
        .constant("Memo")
    }

    var destinationError: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }

    var destinationAdditionalFieldError: AnyPublisher<Error?, Never> {
        Just(nil).eraseToAnyPublisher()
    }
}
