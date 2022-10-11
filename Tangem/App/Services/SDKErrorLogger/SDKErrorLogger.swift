//
//  SDKErrorLogger.swift
//  Tangem
//
//  Created by Sergey Balashov on 11.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation

protocol SDKErrorLogger {
    func logError(_ error: Error, action: Analytics.Action, parameters: [Analytics.ParameterKey: Any])
}

extension SDKErrorLogger {
    func logError(_ error: Error, action: Analytics.Action) {
        logError(error, action: action, parameters: [:])
    }
}
