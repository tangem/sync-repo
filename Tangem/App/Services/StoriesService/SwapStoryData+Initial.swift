//
//  SwapStoryData+Initial.swift
//  TangemApp
//
//  Created by Aleksei Lobankov on 08.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import enum TangemStories.TangemStory

// TODO: @alobankov, remove this file after localization is moved to TangemModules
extension TangemStory.SwapStoryData {
    static let initialWithoutImages = TangemStory.SwapStoryData(
        firstPage: TangemStory.SwapStoryData.Page(title: Localization.swapStoryFirstTitle, subtitle: Localization.swapStoryFirstSubtitle),
        secondPage: TangemStory.SwapStoryData.Page(title: Localization.swapStorySecondTitle, subtitle: Localization.swapStorySecondSubtitle),
        thirdPage: TangemStory.SwapStoryData.Page(title: Localization.swapStoryThirdTitle, subtitle: Localization.swapStoryThirdSubtitle),
        fourthPage: TangemStory.SwapStoryData.Page(title: Localization.swapStoryForthTitle, subtitle: Localization.swapStoryForthSubtitle),
        fifthPage: TangemStory.SwapStoryData.Page(title: Localization.swapStoryFifthTitle, subtitle: Localization.swapStoryFifthSubtitle)
    )
}
