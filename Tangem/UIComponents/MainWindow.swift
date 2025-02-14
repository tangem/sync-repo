//
//  MainWindow.swift
//  TangemApp
//
//  Created by Aleksei Lobankov on 13.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import class UIKit.UIWindow

/// Type-marker used to correctly identify one and only main window of the application.
/// - Note: Used in UIApplication.topViewController property as filtering predicate.
final class MainWindow: UIWindow {}
