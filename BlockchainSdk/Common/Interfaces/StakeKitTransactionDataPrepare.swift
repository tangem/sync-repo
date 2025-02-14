//
//  StakeKitTransactionDataPrepare.swift
//  TangemApp
//
//  Created by Dmitry Fedorov on 14.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

protocol StakeKitTransactionDataPrepare {
    associatedtype RawTransaction

    func prepareDataForSign(transaction: StakeKitTransaction) throws -> Data
    func prepareDataForSend(transaction: StakeKitTransaction, signature: SignatureInfo) throws -> RawTransaction
}
