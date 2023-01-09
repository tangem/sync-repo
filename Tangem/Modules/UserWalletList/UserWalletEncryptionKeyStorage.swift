//
//  UserWalletEncryptionKeyStorage.swift
//  Tangem
//
//  Created by Andrey Chukavin on 02.09.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import CryptoKit
import LocalAuthentication
import TangemSdk

class UserWalletEncryptionKeyStorage {
    private let secureStorage = SecureStorage()
    private let biometricsStorage = BiometricsStorage()
    private let userWalletIdsStorageKey = "user_wallet_ids"

    func fetch(completion: @escaping (Result<[Data: SymmetricKey], Error>) -> Void) {
        do {
            let userWalletIds = try userWalletIds()

            let reason = Localization.biometryTouchIdReason

            AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage fetch - start")

            BiometricsUtil.requestAccess(localizedReason: reason) { [weak self] result in
                guard let self else { return }

                switch result {
                case .failure(let error):
                    AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage fetch - failed \(error)")
                    completion(.failure(error))
                case .success(let context):
                    do {
                        AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage fetch - got context")
                        var keys: [Data: SymmetricKey] = [:]

                        for userWalletId in userWalletIds {
                            let storageKey = self.encryptionKeyStorageKey(for: userWalletId)
                            let encryptionKeyData = try self.biometricsStorage.get(storageKey, context: context)
                            if let encryptionKeyData = encryptionKeyData {
                                AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage fetch - fetched encryption key \(encryptionKeyData.sha256().hex) for userWalletId key \(self.encryptionKeyStorageKey(for: userWalletId))  userWalletId \(userWalletId.hex)")
                                keys[userWalletId] = SymmetricKey(data: encryptionKeyData)
                            } else {
                                AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage fetch - cannot create key for userWalletId key \(self.encryptionKeyStorageKey(for: userWalletId)) userWalletId \(userWalletId.hex)")
                            }
                        }

                        completion(.success(keys))
                    } catch {
                        AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage fetch - cannot fetch \(error)")
                        AppLog.shared.error(error)
                        completion(.failure(error))
                    }
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }

    func add(_ userWallet: UserWallet) {
        AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage add userWalletId \(encryptionKeyStorageKey(for: userWallet.userWalletId)) userWalletId \(userWallet.userWalletId.hex) - starting")
        let cardInfo = userWallet.cardInfo()

        guard let encryptionKey = UserWalletEncryptionKeyFactory().encryptionKey(from: cardInfo) else {
            AppLog.shared.debug("Failed to get encryption key for UserWallet")
            return
        }

        do {
            let userWalletIds = try userWalletIds()
            if userWalletIds.contains(userWallet.userWalletId) {
                AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage add userWalletId \(encryptionKeyStorageKey(for: userWallet.userWalletId)) userWalletId \(userWallet.userWalletId.hex) - already saved")
                return
            }

            try addUserWalletId(userWallet)
            AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage did add user wallet id to set")

            let encryptionKeyData = encryptionKey.symmetricKey.dataRepresentationWithHexConversion
            try biometricsStorage.store(encryptionKeyData, forKey: encryptionKeyStorageKey(for: userWallet))
            AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage add userWalletId \(encryptionKeyStorageKey(for: userWallet.userWalletId)) userWalletId \(userWallet.userWalletId.hex) - saved successfully")
        } catch {
            AppLog.shared.debug("BIO UserWalletEncryptionKeyStorage add userWalletId \(encryptionKeyStorageKey(for: userWallet.userWalletId)) userWalletId \(userWallet.userWalletId.hex) - failed to save \(error)")
            AppLog.shared.debug("Failed to add UserWallet ID to the list")
            AppLog.shared.error(error)
            return
        }
    }

    func delete(_ userWallet: UserWallet) {
        do {
            try deleteUserWalletId(userWallet)

            try biometricsStorage.delete(encryptionKeyStorageKey(for: userWallet))

            if AppSettings.shared.saveAccessCodes {
                let accessCodeRepository = AccessCodeRepository()
                try accessCodeRepository.deleteAccessCode(for: Array(userWallet.associatedCardIds))
            }
        } catch {
            AppLog.shared.debug("Failed to delete user wallet list encryption key")
            AppLog.shared.error(error)
        }
    }

    func clear() {
        do {
            let userWalletIds = try userWalletIds()
            try saveUserWalletIds([])
            for userWalletId in userWalletIds {
                try biometricsStorage.delete(encryptionKeyStorageKey(for: userWalletId))
            }
        } catch {
            AppLog.shared.debug("Failed to clear user wallet encryption keys")
            AppLog.shared.error(error)
        }
    }

    // MARK: - Saving the list of UserWallet IDs

    private func encryptionKeyStorageKey(for userWallet: UserWallet) -> String {
        encryptionKeyStorageKey(for: userWallet.userWalletId)
    }

    private func encryptionKeyStorageKey(for userWalletId: Data) -> String {
        "user_wallet_encryption_key_\(userWalletId.hex)"
    }

    private func addUserWalletId(_ userWallet: UserWallet) throws {
        var ids = try userWalletIds()
        ids.insert(userWallet.userWalletId)
        try saveUserWalletIds(ids)
    }

    private func deleteUserWalletId(_ userWallet: UserWallet) throws {
        var ids = try userWalletIds()
        ids.remove(userWallet.userWalletId)
        try saveUserWalletIds(ids)
    }

    private func userWalletIds() throws -> Set<Data> {
        guard let data = try secureStorage.get(userWalletIdsStorageKey) else {
            return []
        }
        return try JSONDecoder().decode(Set<Data>.self, from: data)
    }

    private func saveUserWalletIds(_ userWalletIds: Set<Data>) throws {
        if userWalletIds.isEmpty {
            try secureStorage.delete(userWalletIdsStorageKey)
        } else {
            let data = try JSONEncoder().encode(userWalletIds)
            try secureStorage.store(data, forKey: userWalletIdsStorageKey)
        }
    }
}
