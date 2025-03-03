//
//  CommonUnspentOutputManager.swift
//  TangemApp
//
//  Created by Sergey Balashov on 24.02.2025.
//  Copyright © 2025 Tangem AG. All rights reserved.
//

import TangemFoundation

class CommonUnspentOutputManager {
    private var outputs: ThreadSafeContainer<[Data: [UnspentOutput]]> = [:]
}

extension CommonUnspentOutputManager: UnspentOutputManager {
    func update(outputs: [UnspentOutput], for script: Data) {
        self.outputs.mutate { $0[script] = outputs }
    }

    func outputs(for amount: UInt64, script: Data) throws -> [UnspentOutput] {
        guard let outputs = outputs[script] else {
            BSDKLogger.error(error: "No outputs for \(script)")
            throw Errors.noOutputs
        }

        // TODO: Add binary search
        // https://tangem.atlassian.net/browse/IOS-8322
        return outputs
    }

    func allOutputs() -> [ScriptUnspentOutput] {
        outputs.read().flatMap { key, value in
            value.map { ScriptUnspentOutput(output: $0, script: key) }
        }
    }

    func confirmedBalance() -> UInt64 {
        outputs.read().flatMap { $0.value }.filter { $0.isConfirmed }.reduce(0) { $0 + $1.amount }
    }

    func unconfirmedBalance() -> UInt64 {
        outputs.read().flatMap { $0.value }.filter { !$0.isConfirmed }.reduce(0) { $0 + $1.amount }
    }
}

extension CommonUnspentOutputManager {
    enum Errors: LocalizedError {
        case noOutputs

        var errorDescription: String? {
            switch self {
            case .noOutputs:
                return "No outputs"
            }
        }
    }
}
