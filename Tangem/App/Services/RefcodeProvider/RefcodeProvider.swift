//
//  RefcodeProvider.swift
//  Tangem
//
//  Created by Alexander Skibin on 25.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

enum Refcode: String, CaseIterable {
    case ring
    case partner
    case changeNow = "ChangeNow"

    var batchId: String? {
        switch self {
        case .partner:
            return "AF990015"
        case .changeNow:
            return "BB000013"
        case .ring:
            return nil
        }
    }
}

protocol RefcodeProvider {
    func getRefcode() -> Refcode?
}
