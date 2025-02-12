//
//  StoryDataCache.swift
//  TangemModules
//
//  Created by Aleksei Lobankov on 07.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

public protocol StoryDataCache {
    func store(story: TangemStory) async
    func retrieveStory(with storyId: TangemStory.ID) async -> TangemStory?
    func removeStory(with storyId: TangemStory.ID) async
}
