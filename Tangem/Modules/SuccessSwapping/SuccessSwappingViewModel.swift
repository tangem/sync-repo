//
//  SuccessSwappingViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import SwiftUI

final class SuccessSwappingViewModel: ObservableObject, Identifiable {
    let id = UUID()

    // MARK: - ViewState

    var sourceFormatted: String {
        source.formatted
    }

    var resultFormatted: String {
        result.formatted
    }

    // MARK: - Dependencies

    private let source: CurrencyPrice
    private let result: CurrencyPrice
    private unowned let coordinator: SuccessSwappingRoutable

    init(
        source: CurrencyPrice,
        result: CurrencyPrice,
        coordinator: SuccessSwappingRoutable
    ) {
        self.source = source
        self.result = result
        self.coordinator = coordinator
    }

    func doneDidTapped() {
        coordinator.userDidTapMainButton()
    }
}
