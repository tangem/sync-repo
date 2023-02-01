//
//  SwappingSuccessViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import TangemExchange

final class SwappingSuccessViewModel: ObservableObject {
    // MARK: - ViewState

    var sourceFormatted: String {
        inputModel.sourceCurrencyAmount.formatted
    }

    var resultFormatted: String {
        inputModel.resultCurrencyAmount.formatted
    }

    var isViewInExplorerAvailable: Bool {
        explorerLink != nil
    }

    // MARK: - Dependencies

    private let inputModel: SwappingSuccessInputModel
    private let explorerURLService: ExplorerURLService
    private unowned let coordinator: SwappingSuccessRoutable

    private var explorerLink: URL? {
        explorerURLService.getExplorerURL(
            for: inputModel.sourceCurrencyAmount.currency.blockchain,
            transactionID: inputModel.transactionHash
        )
    }

    init(
        inputModel: SwappingSuccessInputModel,
        explorerURLService: ExplorerURLService,
        coordinator: SwappingSuccessRoutable
    ) {
        self.inputModel = inputModel
        self.explorerURLService = explorerURLService
        self.coordinator = coordinator
    }

    func didTapViewInExplorer() {
        guard let url = explorerLink else { return }

        coordinator.openExplorer(
            url: url,
            currencyName: inputModel.sourceCurrencyAmount.currency.name
        )
    }

    func didTapClose() {
        coordinator.didTapCloseButton()
    }
}
