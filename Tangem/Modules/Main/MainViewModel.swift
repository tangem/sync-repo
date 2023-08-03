//
//  MainViewModel.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

final class MainViewModel: ObservableObject {
    @Injected(\.userWalletRepository) private var userWalletRepository: UserWalletRepository

    // MARK: - ViewState

    @Published var pages: [MainUserWalletPageBuilder] = []
    @Published var selectedCardIndex = 0
    @Published var isHorizontalScrollDisabled = false
    @Published var errorAlert: AlertBinder?

    // MARK: - Dependencies

    private let mainUserWalletPageBuilderFactory: MainUserWalletPageBuilderFactory
    private weak var coordinator: MainRoutable?

    private var bag = Set<AnyCancellable>()

    // MARK: - Initializers

    init(
        coordinator: MainRoutable,
        mainUserWalletPageBuilderFactory: MainUserWalletPageBuilderFactory
    ) {
        self.coordinator = coordinator
        self.mainUserWalletPageBuilderFactory = mainUserWalletPageBuilderFactory

        pages = mainUserWalletPageBuilderFactory.createPages(from: userWalletRepository.models)
    }

    convenience init(
        selectedUserWalletId: UserWalletId,
        coordinator: MainRoutable,
        mainUserWalletPageBuilderFactory: MainUserWalletPageBuilderFactory
    ) {
        self.init(coordinator: coordinator, mainUserWalletPageBuilderFactory: mainUserWalletPageBuilderFactory)

        if let selectedIndex = pages.firstIndex(where: { $0.id == selectedUserWalletId }) {
            selectedCardIndex = selectedIndex
        }
    }

    // MARK: - Internal functions

    func scanCardAction() {
        Analytics.beginLoggingCardScan(source: .main)
        if AppSettings.shared.saveUserWallets {
            scanCard()
        } else {
            coordinator?.close(newScan: true)
        }
    }

    func openDetails() {
        // TODO: Refactor navigation to UserWalletModel instead of CardViewModel
        guard let cardViewModel = userWalletRepository.models[selectedCardIndex] as? CardViewModel else {
            log("Failed to cast user wallet model to CardViewModel")
            return
        }

        coordinator?.openDetails(for: cardViewModel)
    }

    func onPullToRefresh(completionHandler: @escaping RefreshCompletionHandler) {
        isHorizontalScrollDisabled = true
        let completion = { [weak self] in
            self?.isHorizontalScrollDisabled = false
            completionHandler()
        }
        let page = pages[selectedCardIndex]
        let model = userWalletRepository.models[selectedCardIndex]

        switch page {
        case .singleWallet:
            model.walletModelsManager.updateAll(silent: false, completion: completion)
        case .multiWallet:
            model.userTokenListManager.updateLocalRepositoryFromServer { _ in
                model.walletModelsManager.updateAll(silent: true, completion: completion)
            }
        }
    }

    // MARK: - Scan card

    private func scanCard() {
        userWalletRepository.add { [weak self] result in
            guard let self, let result else {
                return
            }

            switch result {
            case .troubleshooting:
                // TODO: https://tangem.atlassian.net/browse/IOS-4127
                break
            case .onboarding:
                // TODO: https://tangem.atlassian.net/browse/IOS-4127
                break
            case .error(let error):
                if let userWalletRepositoryError = error as? UserWalletRepositoryError {
                    errorAlert = userWalletRepositoryError.alertBinder
                } else {
                    errorAlert = error.alertBinder
                }
            case .success(let cardModel), .partial(let cardModel, _):
                addNewPage(for: cardModel)
            }
        }
    }

    private func addNewPage(for userWalletModel: UserWalletModel) {
        let newPage = mainUserWalletPageBuilderFactory.createPage(for: userWalletModel)
        let newPageIndex = pages.count
        pages.append(newPage)
        selectedCardIndex = newPageIndex
    }

    // MARK: - Private functions

    private func bind() {}

    private func log(_ message: String) {
        AppLog.shared.debug("[Main V2] \(message)")
    }
}
