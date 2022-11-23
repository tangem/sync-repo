//
//  SwappingCoordinator.swift
//  Tangem
//
//  Created by Sergey Balashov on 18.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

class SwappingCoordinator: CoordinatorObject {
    let dismissAction: Action
    let popToRootAction: ParamsAction<PopToRootOptions>

    // MARK: - Root view model

    @Published private(set) var rootViewModel: SwappingViewModel?

    // MARK: - Child coordinators

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
        rootViewModel = SwappingViewModel(coordinator: self)
    }
}

// MARK: - Options

extension SwappingCoordinator {
    enum Options {

    }
}

// MARK: - SwappingRoutable

extension SwappingCoordinator: SwappingRoutable {
    func presentSuccessView(fromCurrency: String, toCurrency: String) {
        successSwappingViewModel = SuccessSwappingViewModel(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            coordinator: self
        )
    }
    
    func presentExchangeableTokenListView(inputModel: SwappingPermissionViewModel.InputModel) {
        swappingPermissionViewModel = SwappingPermissionViewModel(inputModel: inputModel, coordinator: self)
    }
}

// MARK: - SuccessSwappingRoutable

extension SwappingCoordinator: SuccessSwappingRoutable {}

// MARK: - SwappingPermissionRoutable

extension SwappingCoordinator: SwappingPermissionRoutable {
    func userDidApprove() {
        swappingPermissionViewModel = nil
    }
    
    func userDidCancel() {
        swappingPermissionViewModel = nil
    }
}
