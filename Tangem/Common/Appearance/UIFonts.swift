//
//  UIFonts.swift
//  Tangem
//
//  Created by Andrew Son on 17/03/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import UIKit

enum UIFonts {
    enum Regular {
        static let body: UIFont = FeatureProvider.isAvailable(.dynamicFonts) ? .preferredFont(forTextStyle: .body) : .systemFont(ofSize: 17, weight: .regular)

        static let caption1: UIFont = FeatureProvider.isAvailable(.dynamicFonts) ? .preferredFont(forTextStyle: .caption1) : .systemFont(ofSize: 12, weight: .regular)
    }
}
