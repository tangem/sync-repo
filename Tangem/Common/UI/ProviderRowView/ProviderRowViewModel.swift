//
//  ProviderRowViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 07.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct ProviderRowViewModel: Identifiable {
    var id: Int { provider.hashValue }

    let provider: Provider
    let providerTitleType: ProviderTitleType
    let isDisabled: Bool
    let badge: Badge?
    let subtitles: [Subtitle]
    let detailsType: DetailsType?
    let tapAction: (() -> Void)?

    init(
        provider: Provider,
        providerTitleType: ProviderTitleType = .onlyName,
        isDisabled: Bool,
        badge: Badge?,
        subtitles: [Subtitle],
        detailsType: DetailsType?,
        tapAction: (() -> Void)? = nil
    ) {
        self.provider = provider
        self.providerTitleType = providerTitleType
        self.isDisabled = isDisabled
        self.badge = badge
        self.subtitles = subtitles
        self.detailsType = detailsType
        self.tapAction = tapAction
    }
}

extension ProviderRowViewModel {
    enum ProviderTitleType {
        case withPrefix
        case onlyName
    }

    struct Provider: Hashable {
        let id: String
        let iconURL: URL?
        let name: String
        let type: String
    }

    enum Badge: String, Hashable {
        case permissionNeeded
        case bestRate
    }

    enum Subtitle: Hashable, Identifiable {
        var id: Int { hashValue }

        case text(String)
        case percent(String, signType: ChangeSignType)
    }

    enum DetailsType: Hashable {
        case selected
        case chevron
    }
}
