//
//  FinalizeStoryUseCase.swift
//  TangemModules
//
//  Created by Aleksei Lobankov on 09.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

public final class FinalizeStoryUseCase {
    private let storyAvailabilityService: any StoryAvailabilityService
    private let storyDataCache: any StoryDataCache

    public init(storyAvailabilityService: some StoryAvailabilityService, storyDataCache: some StoryDataCache) {
        self.storyAvailabilityService = storyAvailabilityService
        self.storyDataCache = storyDataCache
    }

    public func callAsFunction(_ storyId: TangemStory.ID) async {
        storyAvailabilityService.markStoryAsShown(storyId: storyId)
        await storyDataCache.removeStory(with: storyId)
    }
}
