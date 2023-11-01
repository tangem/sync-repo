//
//  SendViewModel.swift
//  Tangem
//
//  Created by Andrey Chukavin on 30.10.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class SendViewModel: ObservableObject {
    // MARK: - ViewState

    @Published var step: SendStep
    @Published var currentStepInvalid: Bool = false

    var title: String {
        step.name
    }

    var showNavigationButtons: Bool {
        step.hasNavigationButtons
    }

    var showBackButton: Bool {
        step.previousStep != nil
    }

    var showNextButton: Bool {
        step.nextStep != nil
    }

    // MARK: - Dependencies

    let sendModel: SendModel

    private unowned let coordinator: SendRoutable

    private var currentStepValid: AnyPublisher<Bool, Never> {
        $step
            .flatMap { [weak self] step in
                #warning("just")
                guard let self else {
                    return Just(true).eraseToAnyPublisher()
                }

                switch step {
                case .amount:
                    return sendModel.amountError
                        .map {
                            $0 == nil
                        }
                        .eraseToAnyPublisher()
                case .destination:
                    return Publishers.CombineLatest(sendModel.destinationError, sendModel.destinationAdditionalFieldError)
                        .map {
                            $0 == nil && $1 == nil
                        }
                        .eraseToAnyPublisher()
                case .fee:
                    #warning("just")
                    return Just(true).eraseToAnyPublisher()
                case .summary:
                    return Just(true).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    init(coordinator: SendRoutable) {
        self.coordinator = coordinator
        sendModel = SendModel()
        step = .amount

        bind()
    }

    func next() {
        if let nextStep = step.nextStep {
            step = nextStep
        }
    }

    func back() {
        if let previousStep = step.previousStep {
            step = previousStep
        }
    }

    private func bind() {
        currentStepValid
            .map {
                !$0
            }
            .assign(to: &$currentStepInvalid)
    }
}

extension SendViewModel: SendSummaryRoutable {
    func openStep(_ step: SendStep) {
        withAnimation(.easeOut(duration: 0.3)) {
            self.step = step
        }
    }

    func send() {
        sendModel.send()
    }
}
