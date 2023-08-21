//
//  LockedUserTokenListManager.swift
//  Tangem
//
//  Created by Andrew Son on 28/07/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine

struct LockedUserTokenListManager: UserTokenListManager {
    var isInitialSyncPerformed: Bool { false }

    var initialSyncPublisher: AnyPublisher<Bool, Never> { .just(output: false) }

    var userTokens: [StorageEntry.V3.Entry] { [] }

    var userTokensPublisher: AnyPublisher<[StorageEntry.V3.Entry], Never> { .just(output: []) }

    var groupingOptionPublisher: AnyPublisher<StorageEntry.V3.Grouping, Never> { .just(output: .none) }

    var sortingOptionPublisher: AnyPublisher<StorageEntry.V3.Sorting, Never> { .just(output: .manual) }

    func update(_ updates: [UserTokenListUpdateType], shouldUpload: Bool) {}

    func updateLocalRepositoryFromServer(result: @escaping (Result<Void, Error>) -> Void) {
        result(.success(()))
    }

    func updateServerFromLocalRepository() {}
}
