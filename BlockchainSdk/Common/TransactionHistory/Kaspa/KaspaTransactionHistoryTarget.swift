//
//  KaspaTransactionHistoryTarget.swift
//  BlockchainSdk
//
//  Created by Dmitry Fedorov on 04.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation
import Moya

struct KaspaTransactionHistoryTarget {
    let type: TargetType
}

extension KaspaTransactionHistoryTarget {
    enum TargetType {
        case getCoinTransactionHistory(address: String, page: Int, limit: Int)
        case getTokenTransactionHistory(address: String, contract: String, page: Int, limit: Int)
    }
}

extension KaspaTransactionHistoryTarget: TargetType {
    var baseURL: URL {
        switch type {
        case .getCoinTransactionHistory:
            URL(string: "https://api.kaspa.org/")!
        case .getTokenTransactionHistory:
            URL(string: "https://api.kasplex.org/v1/")!
        }
    }

    var path: String {
        switch type {
        case .getCoinTransactionHistory(let address, let page, let limit):
            "addresses/\(address)/full-transactions"
        case .getTokenTransactionHistory(address: let address, contract: let contract, _, _):
            "krc20/oplist?address=\(address)&tick=\(contract)"
        }
    }

    var method: Moya.Method {
        switch type {
        case .getCoinTransactionHistory, .getTokenTransactionHistory: .get
        }
    }

    var task: Moya.Task {
        switch type {
        case .getCoinTransactionHistory(_, let page, let limit):
            .requestParameters(
                parameters: ["limit": limit, "offset": page, "resolve_previous_outpoints": "light"],
                encoding: URLEncoding()
            )
        case .getTokenTransactionHistory:
            .requestPlain
        }
    }

    var headers: [String: String]? {
        nil
    }
}
