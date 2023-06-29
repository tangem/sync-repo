//
//  PromotionService.swift
//  Tangem
//
//  Created by Andrey Chukavin on 31.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Combine
import TangemSdk
import BlockchainSdk

class PromotionService {
    @Injected(\.tangemApiService) private var tangemApiService: TangemApiService

    var readyForAwardPublisher: AnyPublisher<Void, Never> {
        readyForAwardSubject.eraseToAnyPublisher()
    }

    let currentProgramName = "1inch"
    private let promoCodeStorageKey = "promo_code"
    private let finishedPromotionNamesStorageKey = "finished_promotion_names"

    var awardAmount: Int?
    var promotionAvailable: Bool = false

    private let readyForAwardSubject = PassthroughSubject<Void, Never>()

    init() {}
}

extension PromotionService: PromotionServiceProtocol {
    var promoCode: String? {
        let secureStorage = SecureStorage()
        guard
            let promoCodeData = try? secureStorage.get(promoCodeStorageKey),
            let promoCode = String(data: promoCodeData, encoding: .utf8)
        else {
            return nil
        }

        return promoCode
    }

    func didBecomeReadyForAward() {
        readyForAwardSubject.send(())
    }

    func checkPromotion(timeout: TimeInterval?) async {
        let promotionAvailable: Bool
        let award: Int?

        if !FeatureProvider.isAvailable(.learnToEarn) || currentPromotionIsFinished() {
            promotionAvailable = false
            award = nil
        } else {
            do {
                let promotion = try await tangemApiService.promotion(programName: currentProgramName, timeout: timeout)

                promotionAvailable = (promotion.status == .active)

                if promotion.status == .finished {
                    markCurrentPromotionAsFinished(true)
                }

                if promoCode != nil {
                    award = promotion.awardForNewCard
                } else {
                    award = promotion.awardForOldCard
                }
            } catch {
                promotionAvailable = false
                award = nil
            }
        }

        awardAmount = award
        self.promotionAvailable = promotionAvailable
    }

    func setPromoCode(_ promoCode: String?) {
        do {
            let secureStorage = SecureStorage()

            if let promoCode {
                guard let promoCodeData = promoCode.data(using: .utf8) else { return }

                try secureStorage.store(promoCodeData, forKey: promoCodeStorageKey)
            } else {
                try secureStorage.delete(promoCodeStorageKey)
            }
        } catch {
            AppLog.shared.error(error)
            AppLog.shared.error("Failed to update promo code")
        }
    }

    func checkIfCanGetAward(userWalletId: String) async throws {
        if let promoCode {
            try await tangemApiService.validateNewUserPromotionEligibility(walletId: userWalletId, code: promoCode)
        } else {
            try await tangemApiService.validateOldUserPromotionEligibility(walletId: userWalletId, programName: currentProgramName)
        }
    }

    func claimReward(userWalletId: String, userTokensManager: UserTokensManager, walletModelsManager: WalletModelsManager) async throws -> Bool {
        guard let address = try await rewardAddress(userTokensManager: userTokensManager, walletModelsManager: walletModelsManager) else { return false }

        if let promoCode {
            try await tangemApiService.awardNewUser(walletId: userWalletId, address: address, code: promoCode)
        } else {
            try await tangemApiService.awardOldUser(walletId: userWalletId, address: address, programName: currentProgramName)
        }

        markCurrentPromotionAsFinished(true)

        return true
    }

    func finishedPromotionNames() -> Set<String> {
        do {
            let storage = SecureStorage()
            guard let data = try storage.get(finishedPromotionNamesStorageKey) else { return [] }
            return try JSONDecoder().decode(Set<String>.self, from: data)
        } catch {
            AppLog.shared.error(error)
            AppLog.shared.debug("Failed to get finished promotions")
            return []
        }
    }

    func resetFinishedPromotions() {
        if AppEnvironment.current.isProduction {
            AppLog.shared.debug("Trying to reset finished promotions in production. Not allowed")
            fatalError("Trying to reset finished promotions in production. Not allowed")
        }

        saveFinishedPromotions([])
    }
}

extension PromotionService {
    private func rewardAddress(userTokensManager: UserTokensManager, walletModelsManager: WalletModelsManager) async throws -> String? {
        let promotion = try await tangemApiService.promotion(programName: currentProgramName, timeout: nil)

        guard
            let awardBlockchain = Blockchain(from: promotion.awardPaymentToken.networkId),
            let awardToken = promotion.awardPaymentToken.storageToken
        else {
            throw TangemAPIError(code: .decode)
        }

        do {
            try await userTokensManager.add(.token(awardToken, awardBlockchain), derivationPath: nil)
            let address = walletModelsManager.walletModels.first(where: { $0.amountType.token == awardToken })?.defaultAddress
            return address
        } catch {
            if error.toTangemSdkError().isUserCancelled {
                return nil
            } else {
                throw error
            }
        }
    }

    private func currentPromotionIsFinished() -> Bool {
        finishedPromotionNames().contains(currentProgramName)
    }

    private func markCurrentPromotionAsFinished(_ finished: Bool) {
        let finishedPromotionNames = finishedPromotionNames()

        var newFinishedPromotionNames = finishedPromotionNames
        if finished {
            newFinishedPromotionNames.insert(currentProgramName)
        } else {
            newFinishedPromotionNames.remove(currentProgramName)
        }

        guard finishedPromotionNames != newFinishedPromotionNames else { return }

        saveFinishedPromotions(newFinishedPromotionNames)
    }

    private func saveFinishedPromotions(_ programNames: Set<String>) {
        do {
            let data = try JSONEncoder().encode(programNames)

            let storage = SecureStorage()
            try storage.store(data, forKey: finishedPromotionNamesStorageKey)
        } catch {
            AppLog.shared.error(error)
            AppLog.shared.debug("Failed to set finished programs")
        }
    }
}
