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
        case .getCoinTransactionHistory(address: let address, page: let page, limit: let limit):
            <#code#>
        case .getTokenTransactionHistory(address: let address, contract: let contract, page: let page, limit: let limit):
            <#code#>
        }
    }
    
    var path: String {
        <#code#>
    }
    
    var method: Moya.Method {
        <#code#>
    }
    
    var task: Moya.Task {
        <#code#>
    }
    
    var headers: [String : String]? {
        <#code#>
    }
    
    
}
