//
//  ViewHierarchySnapshottingInitializable.swift
//  TangemApp
//
//  Created by Alexander Osokin on 07/02/2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

/// Interface that initializes `OverlayContentContainerViewControllerAdapter`'
protocol ViewHierarchySnapshottingInitializable: AnyObject {
    func set(_ viewHierarchySnapshotter: ViewHierarchySnapshotting)
}
