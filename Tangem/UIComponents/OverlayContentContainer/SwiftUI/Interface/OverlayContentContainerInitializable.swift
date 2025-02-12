//
//  OverlayContentContainerInitializable.swift
//  Tangem
//
//  Created by Alexander Osokin on 06/02/2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

/// Interface that initializes `OverlayContentContainerViewControllerAdapter`'
protocol OverlayContentContainerInitializable: AnyObject {
    func set(_ containerViewController: OverlayContentContainerViewController)
}
