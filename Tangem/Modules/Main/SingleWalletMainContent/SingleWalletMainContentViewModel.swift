//
//  SingleWalletMainContentViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import CombineExt

final class SingleWalletMainContentViewModel: SingleTokenBaseViewModel, ObservableObject {
    // MARK: - ViewState

    @Published var notificationInputs: [NotificationViewInput] = []

    // MARK: - Dependencies

    private let userWalletNotificationManager: NotificationManager

    private var updateSubscription: AnyCancellable?
    private var bag: Set<AnyCancellable> = []

    private weak var delegate: SingleWalletMainContentDelegate?

    init(
        userWalletModel: UserWalletModel,
        walletModel: WalletModel,
        exchangeUtility: ExchangeCryptoUtility,
        userWalletNotificationManager: NotificationManager,
        tokenNotificationManager: NotificationManager,
        tokenRouter: SingleTokenRoutable,
        delegate: SingleWalletMainContentDelegate?
    ) {
        self.userWalletNotificationManager = userWalletNotificationManager
        self.delegate = delegate

        super.init(
            userWalletModel: userWalletModel,
            walletModel: walletModel,
            exchangeUtility: exchangeUtility,
            notificationManager: tokenNotificationManager,
            tokenRouter: tokenRouter
        )

        bind()
    }

    override func presentActionSheet(_ actionSheet: ActionSheetBinder) {
        delegate?.present(actionSheet: actionSheet)
    }

    private func bind() {
        let userWalletNotificationPublisher = userWalletNotificationManager
            .notificationPublisher
            .receive(on: DispatchQueue.main)
            .share(replay: 1)

        userWalletNotificationPublisher
            .assign(to: \.notificationInputs, on: self, ownership: .weak)
            .store(in: &bag)

        userWalletNotificationPublisher
            .withWeakCaptureOf(self)
            .sink { viewModel, notificationInputs in
                viewModel.delegate?.didChangeNotificationInputs(notificationInputs, for: viewModel.userWalletModel.userWalletId)
            }
            .store(in: &bag)
    }
}
