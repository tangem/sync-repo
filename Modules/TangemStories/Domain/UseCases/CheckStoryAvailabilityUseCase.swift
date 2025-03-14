//
//  CheckStoryAvailabilityUseCase.swift
//  TangemModules
//
//  Created by Aleksei Lobankov on 09.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

public final class CheckStoryAvailabilityUseCase {
    private let storyAvailabilityService: any StoryAvailabilityService

    public init(storyAvailabilityService: some StoryAvailabilityService) {
        self.storyAvailabilityService = storyAvailabilityService
    }

    public func callAsFunction(_ storyId: TangemStory.ID) -> Bool {
        storyAvailabilityService.checkStoryAvailability(storyId: storyId)
    }
}
