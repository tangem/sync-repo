//
//  PromotionServiceProtocol.swift
//  Tangem
//
//  Created by Andrey Chukavin on 31.05.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

protocol PromotionServiceProtocol {
    var programName: String { get }
    var promoCode: String? { get }

    func setPromoCode(_ promoCode: String?)
    func getReward(userWalletId: String, storageEntryAdding: StorageEntryAdding) throws
}

private struct PromotionServiceKey: InjectionKey {
    static var currentValue: PromotionServiceProtocol = PromotionService()
}

extension InjectedValues {
    var promotionService: PromotionServiceProtocol {
        get { Self[PromotionServiceKey.self] }
        set { Self[PromotionServiceKey.self] = newValue }
    }
}
