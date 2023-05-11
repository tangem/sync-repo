//
//  SwappingApproveViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 21.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Combine
import TangemSwapping
import UIKit
import enum TangemSdk.TangemSdkError

final class SwappingApproveViewModel: ObservableObject, Identifiable {
    // MARK: - ViewState

    @Published var menuRowViewModel: DefaultMenuRowViewModel<SwappingApprovePolicy>?
    @Published var selectedAction: SwappingApprovePolicy = .unlimited
    @Published var feeRowViewModel: DefaultRowViewModel?
    @Published var isLoading: Bool = false
    @Published var errorAlert: AlertBinder?

    var tokenSymbol: String {
        sourceCurrency.symbol
    }

    // MARK: - Dependencies

    // TODO: Will be removed in https://tangem.atlassian.net/browse/IOS-3448
    private let inputModel: SwappingPermissionInputModel
    private var sourceCurrency: Currency { inputModel.transactionData.sourceCurrency }
    private let transactionSender: SwappingTransactionSender
    private unowned let coordinator: SwappingApproveRoutable

    private var didBecomeActiveNotificationCancellable: AnyCancellable?

    init(
        inputModel: SwappingPermissionInputModel,
        transactionSender: SwappingTransactionSender,
        coordinator: SwappingApproveRoutable
    ) {
        self.inputModel = inputModel
        self.transactionSender = transactionSender
        self.coordinator = coordinator

        setupView()
    }

    func didTapInfoButton() {
        errorAlert = AlertBinder(
            title: Localization.swappingApproveInformationTitle,
            message: Localization.swappingApproveInformationText
        )
    }

    func didTapApprove() {
        // TODO: https://tangem.atlassian.net/browse/IOS-3448
        let data = inputModel.transactionData

        Analytics.log(
            event: .swapButtonPermissionApprove,
            params: [
                .sendToken: data.sourceCurrency.symbol,
                .receiveToken: data.destinationCurrency.symbol,
            ]
        )

        Task {
            do {
                _ = try await transactionSender.sendTransaction(data)
                await didSendApproveTransaction(transactionData: data)
            } catch TangemSdkError.userCancelled {
                // Do nothing
            } catch {
                await runOnMain {
                    errorAlert = AlertBinder(title: Localization.commonError, message: error.localizedDescription)
                }
            }
        }
    }

    func didTapCancel() {
        Analytics.log(.swapButtonPermissionCancel)
        coordinator.userDidCancel()
    }
}

// MARK: - Navigation

extension SwappingApproveViewModel {
    @MainActor
    func didSendApproveTransaction(transactionData: SwappingTransactionData) {
        // We have to waiting close the nfc view to close this permission view
        didBecomeActiveNotificationCancellable = NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .delay(for: 0.3, scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.coordinator.didSendApproveTransaction(transactionData: transactionData)
            }
    }
}

// MARK: - Private

private extension SwappingApproveViewModel {
    func setupView() {
        let transactionData = inputModel.transactionData

        menuRowViewModel = .init(
            title: Localization.swappingPermissionRowsAmount(tokenSymbol),
            actions: [
                SwappingApprovePolicy.unlimited,
                SwappingApprovePolicy.amount(transactionData.sourceAmount),
            ]
        )

        let fiatFee = inputModel.fiatFee.currencyFormatted(code: AppSettings.shared.selectedCurrencyCode)
        let formattedFee = transactionData.fee.groupedFormatted()
        let feeLabel = "\(formattedFee) \(inputModel.transactionData.sourceBlockchain.symbol) (\(fiatFee))"

        feeRowViewModel = DefaultRowViewModel(
            title: Localization.sendFeeLabel,
            detailsType: .text(feeLabel)
        )
    }
}

extension SwappingApprovePolicy: DefaultMenuRowViewModelAction {
    public var id: Int { hashValue }

    public var title: String {
        switch self {
        case .amount:
            return "Current transaction"
        case .unlimited:
            return "Unlimited"
        }
    }
}
