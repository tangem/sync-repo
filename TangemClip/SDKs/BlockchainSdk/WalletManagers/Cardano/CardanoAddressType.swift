//
//  CardanoAddressType.swift
//  BlockchainSdk
//
//  Created by Andrew Son on 31/03/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import Foundation

public enum CardanoAddressType: String {
    case bech32, legacy
    
    public var localizedName: String {
        switch self {
        case .legacy:
            return "address_type_legacy".localized
        case .bech32:
            return "address_type_default".localized
        }
    }
}
