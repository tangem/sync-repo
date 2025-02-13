//
//  StoryDTO.swift
//  TangemApp
//
//  Created by Aleksei Lobankov on 06.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import struct Foundation.URL

enum StoryDTO {}

// MARK: - Response

extension StoryDTO {
    struct Response: Decodable {
        let imageHost: URL
        let story: Story
    }
}

extension StoryDTO.Response {
    struct Story: Decodable {
        let slides: [Slide]
    }

    struct Slide: Decodable {
        let id: String
    }
}
