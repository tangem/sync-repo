//
//  MoralisNetworkResult.EVMNFTCollections.swift
//  TangemNFT
//
//  Created by Andrey Fedorov on 03.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension MoralisNetworkResult {
    struct EVMNFTCollections: Decodable {
        let status: String // TODO: Andrey Fedorov - Enum instead?
        let page: Int
        let cursor: String?
        let pageSize: Int
        let result: [Collection]
    }
}

// MARK: - Nested DTOs

extension MoralisNetworkResult.EVMNFTCollections {
    struct Collection: Decodable {
        let tokenAddress: String
        let possibleSpam: Bool
        let contractType: String // TODO: Andrey Fedorov - Enum instead?
        let name: String
        let symbol: String
        let verifiedCollection: Bool
        let collectionLogo: String?
        let collectionBannerImage: String?
        let floorPrice: String?
        let floorPriceUsd: String?
        let floorPriceCurrency: String?
        let count: Int?
    }
}
