//
//  MoralisNetworkResult.EVMNFT.swift
//  TangemNFT
//
//  Created by Andrey Fedorov on 03.03.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import Foundation

extension MoralisNetworkResult {
    struct EVMNFT: Decodable {
        let amount: String
        let tokenId: String
        let tokenAddress: String
        let contractType: String // TODO: Andrey Fedorov - Enum instead?
        let ownerOf: String
        let lastMetadataSync: String
        let lastTokenURISync: String // TODO: Andrey Fedorov - Check mapping
        let metadata: String?
        let blockNumber: String
        let blockNumberMinted: String?
        let name: String
        let symbol: String
        let tokenHash: String
        let tokenURI: String // TODO: Andrey Fedorov - Check mapping
        let minterAddress: String?
        let rarityRank: Int?
        let rarityPercentage: Double?
        let rarityLabel: String?
        let verifiedCollection: Bool
        let possibleSpam: Bool
        let media: Media?
        let collectionLogo: String?
        let collectionBannerImage: String?
        let floorPrice: String?
        let floorPriceUSD: String? // TODO: Andrey Fedorov - Check mapping
        let floorPriceCurrency: String?
    }
}

// MARK: - Nested DTOs

extension MoralisNetworkResult.EVMNFT {
    struct Media: Decodable {
        let status: String // TODO: Andrey Fedorov - Enum instead?
        let updatedAt: String
        let mimeType: String // TODO: Andrey Fedorov - Check mapping
        let parentHash: String
        let mediaCollection: MediaCollection?
        let originalMediaURL: String // TODO: Andrey Fedorov - Check mapping
    }

    struct MediaCollection: Decodable {
        let low: MediaDetail?
        let medium: MediaDetail?
        let high: MediaDetail?
    }

    struct MediaDetail: Decodable {
        let height: Int
        let width: Int
        let url: String
    }
}
