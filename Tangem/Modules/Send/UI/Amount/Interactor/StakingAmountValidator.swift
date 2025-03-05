//
//  StakingAmountValidator.swift
//  Tangem
//
//  Created by Dmitry Fedorov on 08.08.2024.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation
import BlockchainSdk
import Combine
import TangemStaking

class StakingAmountValidator {
    private let tokenItem: TokenItem
    private let validator: TransactionValidator
    private let action: StakingAction.ActionType
    private var minimumAmount: Decimal?
    private let stakingManagerStatePublisher: AnyPublisher<StakingManagerState, Never>
    private var bag = Set<AnyCancellable>()

    init(
        tokenItem: TokenItem,
        validator: TransactionValidator,
        action: StakingAction.ActionType,
        stakingManagerStatePublisher: AnyPublisher<StakingManagerState, Never>
    ) {
        self.tokenItem = tokenItem
        self.validator = validator
        self.stakingManagerStatePublisher = stakingManagerStatePublisher
        self.action = action
        bind()
    }

    private func bind() {
        stakingManagerStatePublisher
            .compactMap { [action, weak self] state -> Decimal? in
                switch state {
                case .availableToStake(let yieldInfo):
                    return self?.enterMinimumRequirement(yield: yieldInfo)
                case .staked(let staked):
                    return switch action {
                    case .unstake: staked.yieldInfo.exitMinimumRequirement
                    case .pending(.stake): self?.enterMinimumRequirement(yield: staked.yieldInfo)
                    default: nil
                    }
                default:
                    return nil
                }
            }
            .sink(receiveValue: { [weak self] amount in
                self?.minimumAmount = amount
            })
            .store(in: &bag)
    }

    private func enterMinimumRequirement(yield: YieldInfo) -> Decimal {
        switch (tokenItem.blockchain.stakingDeposit, action) {
        case (.some(let deposit), .pending(.stake)):
            // .pending(.stake) == restake for cardano
            yield.enterMinimumRequirement - deposit
        default:
            yield.enterMinimumRequirement
        }
    }
}

extension StakingAmountValidator: SendAmountValidator {
    func validate(amount: Decimal) throws {
        if let minAmount = minimumAmount, amount < minAmount {
            throw StakingValidationError.amountRequirementError(minAmount: minAmount)
        }

        let amount = Amount(with: tokenItem.blockchain, type: tokenItem.amountType, value: amount)
        try validator.validate(amount: amount)
    }
}

enum StakingValidationError: LocalizedError {
    case amountRequirementError(minAmount: Decimal)

    var errorDescription: String? {
        switch self {
        case .amountRequirementError(let minAmount):
            Localization.stakingAmountRequirementError(minAmount)
        }
    }
}
