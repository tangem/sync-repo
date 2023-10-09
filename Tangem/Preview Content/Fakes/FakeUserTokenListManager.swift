//
//  FakeUserTokenListManager.swift
//  Tangem
//
//  Created by Andrew Son on 02/08/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import struct BlockchainSdk.Token

class FakeUserTokenListManager: UserTokenListManager {
    var initialized: Bool {
        _initialized.value
    }

    var initializedPublisher: AnyPublisher<Bool, Never> {
        _initialized.eraseToAnyPublisher()
    }

    private let _initialized = CurrentValueSubject<Bool, Never>(false)

    var userTokens: [StorageEntry] {
        let converter = StorageEntryConverter()
        return converter.convertToStorageEntries(userTokensListSubject.value.entries)
    }

    var userTokensPublisher: AnyPublisher<[StorageEntry], Never> {
        let converter = StorageEntryConverter()
        return userTokensListSubject
            .map { converter.convertToStorageEntries($0.entries) }
            .eraseToAnyPublisher()
    }

    var userTokensList: StoredUserTokenList { userTokensListSubject.value }

    var userTokensListPublisher: AnyPublisher<StoredUserTokenList, Never> {
        userTokensListSubject.eraseToAnyPublisher()
    }

    private let userTokensListSubject = CurrentValueSubject<StoredUserTokenList, Never>(.empty)

    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            self._initialized.send(true)
        }
    }

    func update(with userTokenList: StoredUserTokenList) {}

    func update(_ type: UserTokenListUpdateType, shouldUpload: Bool) {}

    func upload() {}

    func updateLocalRepositoryFromServer(_ completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let converter = StorageEntryConverter()
            let blockchainNetwork = BlockchainNetwork(.ethereum(testnet: false))
            let tokens: [Token] = [
                .sushiMock,
                .shibaInuMock,
                .tetherMock,
            ]
            let entries = tokens.map { converter.convertToStoredUserToken($0, in: blockchainNetwork) }

            self.userTokensListSubject.send(
                .init(
                    entries: entries,
                    grouping: .none,
                    sorting: .manual
                )
            )
            completion(.success(()))
        }
    }
}
