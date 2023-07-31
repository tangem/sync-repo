//
//  MultiWalletMainHeaderSubtitleProvider.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol MultiWalletMainHeaderSubtitleDataSource: AnyObject {
    var cardsCount: Int { get }
    var updatePublisher: AnyPublisher<Void, Never> { get }
}

class MultiWalletMainHeaderSubtitleProvider: MainHeaderSubtitleProvider {
    var subtitlePublisher: AnyPublisher<MainHeaderSubtitleInfo, Never> {
        subtitleInfoSubject.eraseToAnyPublisher()
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        .just(output: false)
    }

    var containsSensitiveInfo: Bool { false }

    private var suffix: String {
        if isUserWalletLocked {
            return separator + Localization.commonLocked
        }

        if areWalletsImported {
            return separator + Localization.commonSeedPhrase
        }

        return ""
    }

    private let separator = " • "
    private let subtitleInfoSubject: CurrentValueSubject<MainHeaderSubtitleInfo, Never> = .init(.empty)
    private let isUserWalletLocked: Bool
    private let areWalletsImported: Bool

    private unowned var dataSource: MultiWalletMainHeaderSubtitleDataSource
    private var updateSubscription: AnyCancellable?

    init(
        isUserWalletLocked: Bool,
        areWalletsImported: Bool,
        dataSource: MultiWalletMainHeaderSubtitleDataSource
    ) {
        self.isUserWalletLocked = isUserWalletLocked
        self.areWalletsImported = areWalletsImported
        self.dataSource = dataSource
        formatSubtitle()
    }

    private func subscribeToUpdates() {
        updateSubscription = dataSource.updatePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.formatSubtitle()
            })
    }

    private func formatSubtitle() {
        let numberOfCards = dataSource.cardsCount
        let numberOfCardsPrefix = Localization.cardLabelCardCount(numberOfCards)
        let subtitle = numberOfCardsPrefix + suffix
        subtitleInfoSubject.send(.init(message: subtitle, formattingOption: .default))
    }
}
