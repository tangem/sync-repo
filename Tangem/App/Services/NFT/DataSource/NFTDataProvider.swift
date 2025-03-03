//
//  NFTDataProvider.swift
//  Tangem
//
//  Created by m3g0byt3 on 03.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import Combine

// TODO: Andrey Fedorov - Improve naming and public interface if needed
final class NFTDataProvider {
    @Injected(\.userWalletRepository) private var userWalletRepository: UserWalletRepository
    @Injected(\.nftAvailabilityProvider) private var nftAvailabilityProvider: NFTAvailabilityProvider

    private var bag: Set<AnyCancellable> = []

    init() {
        bind()
    }

    // MARK: - Private functions

    private func bind() {
        userWalletRepository.eventProvider
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: weakify(self, forFunction: NFTDataProvider.handleUserWalletRepositoryEvent))
            .store(in: &bag)
    }

    private func handleUserWalletRepositoryEvent(_ event: UserWalletRepositoryEvent) {
        switch event {
        case .deleted(let userWalletIds):
            for userWalletId in userWalletIds {
                nftAvailabilityProvider.setNFTEnabled(false, forUserWalletWithId: userWalletId)
            }
        default:
            break
        }
    }
}
