//
//  ExpressFeeRowViewModel.swift
//  Tangem
//
//  Created by Sergey Balashov on 13.11.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation

struct ExpressFeeRowViewModel: Identifiable {
    var id: String { title }

    let title: String
    let subtitle: String
    let action: () -> Void
}
