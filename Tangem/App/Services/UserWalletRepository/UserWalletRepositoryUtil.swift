//
//  UserWalletRepositoryUtil.swift
//  Tangem
//
//  Created by Andrey Chukavin on 19.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import CryptoKit
import TangemSdk

class UserWalletRepositoryUtil {
    private var fileManager: FileManager {
        FileManager.default
    }
    private var userWalletDirectoryUrl: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("user_wallets", isDirectory: true)
    }

    private let publicDataEncryptionKeyStorageKey = "user_wallet_public_data_encryption_key"

    func removePublicDataEncryptionKey() {
        do {
            let secureStorage = SecureStorage()
            try secureStorage.delete(publicDataEncryptionKeyStorageKey)
        } catch {
            AppLog.shared.debug("Failed to erase public data encryption key")
            AppLog.shared.error(error)
        }
    }

    func savedUserWallets(encryptionKeyByUserWalletId: [Data: SymmetricKey]) -> [UserWallet] {
        do {
            AppLog.shared.debug("BIO UserWalletRepositoryUtil saving user wallets, keys count \(encryptionKeyByUserWalletId.count)")

            guard fileManager.fileExists(atPath: userWalletListPath().path) else {
                AppLog.shared.debug("BIO UserWalletRepositoryUtil saving user wallets. File doesn't exist")
                return []
            }

            let decoder = JSONDecoder.tangemSdkDecoder

            let userWalletsPublicDataEncrypted = try Data(contentsOf: userWalletListPath())
            let userWalletsPublicData = try decrypt(userWalletsPublicDataEncrypted, with: publicDataEncryptionKey())
            var userWallets = try decoder.decode([UserWallet].self, from: userWalletsPublicData)

            AppLog.shared.debug("BIO UserWalletRepositoryUtil iterating \(userWallets.count) user wallets")

            for i in 0 ..< userWallets.count {
                let userWallet = userWallets[i]

                AppLog.shared.debug("BIO UserWalletRepositoryUtil starting \"\(userWallet.name)\" userWalletId \(userWallet.userWalletId.hex)")

                guard let userWalletEncryptionKey = encryptionKeyByUserWalletId[userWallet.userWalletId] else {
                    AppLog.shared.debug("BIO UserWalletRepositoryUtil get data for \"\(userWallet.name)\" userWalletId \(userWallet.userWalletId.hex) encryption key missing")
                    continue
                }

                let sensitiveInformationEncryptedData = try Data(contentsOf: userWalletPath(for: userWallet))
                AppLog.shared.debug("BIO UserWalletRepositoryUtil get data for \"\(userWallet.name)\" userWalletId \(userWallet.userWalletId.hex) data \(sensitiveInformationEncryptedData.sha256().hex)")

                let sensitiveInformationData = try decrypt(sensitiveInformationEncryptedData, with: userWalletEncryptionKey)
                AppLog.shared.debug("BIO UserWalletRepositoryUtil did decrypt")
                let sensitiveInformation = try decoder.decode(UserWallet.SensitiveInformation.self, from: sensitiveInformationData)
                AppLog.shared.debug("BIO UserWalletRepositoryUtil did decode")

                var card = userWallet.card
                card.wallets = sensitiveInformation.wallets
                userWallets[i].card = card
            }

            return userWallets
        } catch {
            AppLog.shared.debug("BIO UserWalletRepositoryUtil get data failed with error \(error)")
            AppLog.shared.error(error)
            return []
        }
    }

    func saveUserWallets(_ userWallets: [UserWallet]) {
        let encoder = JSONEncoder.tangemSdkEncoder

        do {
            if userWallets.isEmpty {
                if fileManager.fileExists(atPath: userWalletDirectoryUrl.path) {
                    try fileManager.removeItem(at: userWalletDirectoryUrl)
                }
                return
            }

            try fileManager.createDirectory(at: userWalletDirectoryUrl, withIntermediateDirectories: true)

            let userWalletsWithoutSensitiveInformation: [UserWallet] = userWallets.map {
                var card = $0.card
                card.wallets = []

                var userWalletWithoutKeys = $0
                userWalletWithoutKeys.card = card
                return userWalletWithoutKeys
            }

            AppLog.shared.debug("BIO UserWalletRepositoryUtil save starting")

            let publicData = try encoder.encode(userWalletsWithoutSensitiveInformation)
            AppLog.shared.debug("BIO UserWalletRepositoryUtil did encode public")
            let publicDataEncoded = try encrypt(publicData, with: publicDataEncryptionKey())
            AppLog.shared.debug("BIO UserWalletRepositoryUtil did encrypt public")
            try publicDataEncoded.write(to: userWalletListPath(), options: .atomic)
            AppLog.shared.debug("BIO UserWalletRepositoryUtil did write public")
            try excludeFromBackup(url: userWalletListPath())
            AppLog.shared.debug("BIO UserWalletRepositoryUtil did exclude public")

            for userWallet in userWallets {
                let cardInfo = userWallet.cardInfo()
                let userWalletEncryptionKey = UserWalletEncryptionKeyFactory().encryptionKey(from: cardInfo)

                guard let encryptionKey = userWalletEncryptionKey else {
                    AppLog.shared.debug("User wallet \(userWallet.card.cardId) failed to generate encryption key")
                    AppLog.shared.debug("BIO UserWalletRepositoryUtil save - \"\(userWallet.name)\" userWalletId \(userWallet.userWalletId.hex) failed to generate")
                    continue
                }

                let sensitiveInformation = UserWallet.SensitiveInformation(wallets: userWallet.card.wallets)
                let sensitiveDataEncoded = try encrypt(encoder.encode(sensitiveInformation), with: encryptionKey.symmetricKey)
                AppLog.shared.debug("BIO UserWalletRepositoryUtil did encrypt sensitive")
                let sensitiveDataPath = userWalletPath(for: userWallet)
                try sensitiveDataEncoded.write(to: sensitiveDataPath, options: .atomic)
                AppLog.shared.debug("BIO UserWalletRepositoryUtil did write sensitive")
                try excludeFromBackup(url: sensitiveDataPath)
                AppLog.shared.debug("BIO UserWalletRepositoryUtil did exclude sensitive")

                AppLog.shared.debug("BIO UserWalletRepositoryUtil save - \"\(userWallet.name)\" userWalletId \(userWallet.userWalletId.hex) sensitiveData \(sensitiveDataEncoded.sha256().hex)")
            }
        } catch {
            AppLog.shared.debug("BIO UserWalletRepositoryUtil save - failed to save user wallets \(error)")
            AppLog.shared.debug("Failed to save user wallets")
            AppLog.shared.error(error)
        }
    }

    private func publicDataEncryptionKey() throws -> SymmetricKey {
        let secureStorage = SecureStorage()

        let encryptionKeyData = try secureStorage.get(publicDataEncryptionKeyStorageKey)
        if let encryptionKeyData = encryptionKeyData {
            let symmetricKey: SymmetricKey = .init(data: encryptionKeyData)
            return symmetricKey
        }

        let newEncryptionKey = SymmetricKey(size: .bits256)
        try secureStorage.store(newEncryptionKey.dataRepresentationWithHexConversion, forKey: publicDataEncryptionKeyStorageKey)
        return newEncryptionKey
    }

    private func userWalletListPath() -> URL {
        userWalletDirectoryUrl.appendingPathComponent("user_wallets.bin")
    }

    private func userWalletPath(for userWallet: UserWallet) -> URL {
        return userWalletDirectoryUrl.appendingPathComponent("user_wallet_\(userWallet.userWalletId.hex).bin")
    }

    private func excludeFromBackup(url originalUrl: URL) throws {
        var url = originalUrl

        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try url.setResourceValues(resourceValues)
    }

    private func decrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try ChaChaPoly.SealedBox(combined: data)
        let decryptedData = try ChaChaPoly.open(sealedBox, using: key)
        return decryptedData
    }

    private func encrypt(_ data: Data, with key: SymmetricKey) throws -> Data {
        let sealedBox = try ChaChaPoly.seal(data, using: key)
        let sealedData = sealedBox.combined
        return sealedData
    }
}
