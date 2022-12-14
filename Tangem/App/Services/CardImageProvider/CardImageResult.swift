//
//  CardImageResult.swift
//  Tangem
//
//  Created by Andrew Son on 14/12/22.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import UIKit

enum CardImageResult {
    case cached(UIImage)
    case downloaded(UIImage)
    case embedded(UIImage)

    var image: UIImage {
        switch self {
        case .cached(let image), .downloaded(let image), .embedded(let image):
            return image
        }
    }
}
