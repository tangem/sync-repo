//
//  StoryAvailabilityService.swift
//  TangemModules
//
//  Created by Aleksei Lobankov on 06.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

public protocol StoryAvailabilityService {
    func checkStoryAvailability(storyId: TangemStory.ID) -> Bool
    func markStoryAsShown(storyId: TangemStory.ID)
}
