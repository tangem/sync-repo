//
//  SwappingCoordinator.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import TangemExchange

class SwappingCoordinator: CoordinatorObject {
    let dismissAction: Action
    let popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Root view model

    @Published private(set) var rootViewModel: SwappingViewModel?

    // MARK: - Child coordinators

    @Published var swappingTokenListViewModel: SwappingTokenListViewModel?
    @Published var swappingPermissionViewModel: SwappingPermissionViewModel?
    @Published var successSwappingViewModel: SuccessSwappingViewModel?

    // MARK: - Child view models

    required init(
        dismissAction: @escaping Action,
        popToRootAction: @escaping ParamsAction<PopToRootOptions>
    ) {
        self.dismissAction = dismissAction
        self.popToRootAction = popToRootAction
    }

    func start(with options: Options) {
        rootViewModel = SwappingConfigurator().createModule(input: options.input, coordinator: self)
    }
}

// MARK: - Options

extension SwappingCoordinator {
    struct Options {
        let input: SwappingConfigurator.InputModel
    }
}

// MARK: - SwappingRoutable

extension SwappingCoordinator: SwappingRoutable {
    func presentExchangeableTokenListView(network: ExchangeBlockchain) {
        swappingTokenListViewModel = SwappingTokenListViewModel(network: network, coordinator: self)
    }

    func presentPermissionView(inputModel: SwappingPermissionViewModel.InputModel) {
        swappingPermissionViewModel = SwappingPermissionViewModel(inputModel: inputModel, coordinator: self)
    }

    func presentSuccessView(fromCurrency: String, toCurrency: String) {
        successSwappingViewModel = SuccessSwappingViewModel(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            coordinator: self
        )
    }
}

// MARK: - SwappingTokenListRoutable

extension SwappingCoordinator: SwappingTokenListRoutable {
    func userDidTap(currency: Currency) {
        swappingTokenListViewModel = nil
        rootViewModel?.userDidRequestChangeDestination(to: currency)
    }
}

// MARK: - SuccessSwappingRoutable

extension SwappingCoordinator: SuccessSwappingRoutable {
    func userDidTapMainButton() {
        successSwappingViewModel = nil
    }
}

// MARK: - SwappingPermissionRoutable

extension SwappingCoordinator: SwappingPermissionRoutable {
    func userDidApprove() {
        swappingPermissionViewModel = nil
    }

    func userDidCancel() {
        swappingPermissionViewModel = nil
    }
}
