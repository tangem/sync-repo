//
//  CardsRepository.swift
//  Tangem
//
//  Created by Alexander Osokin on 11.05.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

protocol CardsRepository {
    var models: [CardViewModel] { get }

    func scan(with batch: String?, requestBiometrics: Bool, _ completion: @escaping (Result<CardViewModel, Error>) -> Void)
    func scanPublisher(with batch: String?, requestBiometrics: Bool) ->  AnyPublisher<CardViewModel, Error>

    func add(_ cardModel: CardViewModel)
    func add(_ cardModels: [CardViewModel])
    func removeModel(withUserWalletId userWalletId: Data)
    func clear()
    func didSwitchToModel(_ cardModel: CardViewModel)
}

private struct CardsRepositoryKey: InjectionKey {
    static var currentValue: CardsRepository = CommonCardsRepository()
}

extension InjectedValues {
    var cardsRepository: CardsRepository {
        get { Self[CardsRepositoryKey.self] }
        set { Self[CardsRepositoryKey.self] = newValue }
    }
}

extension CardsRepository {
    func scanPublisher(with batch: String? = nil, requestBiometrics: Bool = false) ->  AnyPublisher<CardViewModel, Error> {
        scanPublisher(with: batch, requestBiometrics: requestBiometrics)
    }
}

protocol ScanListener {
    func onScan(cardInfo: CardInfo)
}

enum CardsRepositoryError: Error {
    case noCard
}
