//
//  Analytics+Stories.swift
//  TangemApp
//
//  Created by Aleksei Lobankov on 20.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

extension Analytics {
    enum StoriesSource: String {
        case main = "Main"
        case tokenListContextMenu = "Long Tap"
        case token = "Token"
        case markets = "Markets"
    }

    enum StoryType: String {
        case swap = "Swap"
    }
}
