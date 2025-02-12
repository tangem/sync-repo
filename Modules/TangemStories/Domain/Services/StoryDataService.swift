//
//  StoryDataService.swift
//  TangemModules
//
//  Created by Aleksei Lobankov on 07.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

public protocol StoryDataService {
    func fetchStoryImages(with storyId: TangemStory.ID) async throws -> [TangemStory.Image]
}
