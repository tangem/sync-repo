//
// KaspaUtils.swift
// BlockchainSdk
//
// Created by Sergei Iakovlev on 22.10.2024
// Copyright © 2024 Tangem AG. All rights reserved.
//

import Foundation

enum KaspaUtils {
    enum KaspaHashType: String {
        case TransactionSigningHashECDSA
        case TransactionID
        case TransactionHash

        var data: Data {
            rawValue.data(using: .utf8)!
        }
    }
}
