//
//  AnyPublisher+.swift
//  Tangem
//
//  Created by Pavel Grechikhin on 07.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Combine

extension AnyPublisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = first()
                .sink { completion in
                    if case let .failure(error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { output in
                    continuation.resume(returning: output)
                }
        }
    }
}
