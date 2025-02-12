//
//  WCSolanaSignAllTransactionsDTO.swift
//  TangemApp
//
//  Created by GuitarKitty on 10.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

enum WCSolanaSignAllTransactionsDTO {
    struct Body: Codable {
        let transactions: [String]
    }

    struct Response: Codable {
        let transactions: [String]
    }
}
