//
//  StakeKitTransactionBroadcast.swift
//  TangemApp
//
//  Created by Dmitry Fedorov on 14.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//
import Foundation

protocol StakeKitTransactionBroadcast {
    associatedtype RawTransaction
    func broadcast(transaction: StakeKitTransaction, rawTransaction: RawTransaction) async throws -> String
}
