//
//  StoryDataPrefetchService.swift
//  TangemApp
//
//  Created by Aleksei Lobankov on 13.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import TangemStories
import TangemFoundation

final class StoryDataPrefetchService {
    @Injected(\.enrichStoryUseCase) private var enrichStoryUseCase: EnrichStoryUseCase

    func prefetchStoryIfNeeded(_ story: TangemStory) {
        guard !AppSettings.shared.shownStoryIds.contains(story.id.rawValue) else {
            return
        }

        TangemFoundation.runTask(in: self) { strongSelf in
            _ = await strongSelf.enrichStoryUseCase(story)
        }
    }
}
