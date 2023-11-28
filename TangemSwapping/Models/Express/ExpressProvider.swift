//
//  ExpressProvider.swift
//  TangemSwapping
//
//  Created by Sergey Balashov on 02.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

public struct ExpressProvider: Hashable {
    public let id: Id
    public let name: String
    public let url: URL?
    public let type: ExpressProviderType

    public init(id: Id, name: String, url: URL?, type: ExpressProviderType) {
        self.id = id
        self.name = name
        self.url = url
        self.type = type
    }
}

public extension ExpressProvider {
    enum Id: String, Hashable {
        case changeNow = "changenow"
        case oneInch = "1inch"

        internal init(_ id: ExpressDTO.Provider.Id) {
            switch id {
            case .changeNow:
                self = .changeNow
            case .oneInch:
                self = .oneInch
            }
        }

        internal var requestId: ExpressDTO.Provider.Id {
            switch self {
            case .changeNow: return .changeNow
            case .oneInch: return .oneInch
            }
        }
    }
}
