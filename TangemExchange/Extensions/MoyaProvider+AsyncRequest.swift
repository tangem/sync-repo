//
//  MoyaProvider+AsyncRequest.swift
//  TangemExchange
//
//  Created by Sergey Balashov on 24.11.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Moya

extension MoyaProvider {
    func asyncRequest(_ target: Target) async throws -> Response {
        let asyncRequestWrapper = AsyncMoyaRequestWrapper<Response> { [weak self] continuation in
            return self?.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(with: .success(response))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                asyncRequestWrapper.perform(continuation: continuation)
            }
        } onCancel: {
            asyncRequestWrapper.cancel()
        }
    }
}

private class AsyncMoyaRequestWrapper<T> {
    typealias MoyaContinuation = CheckedContinuation<T, Error>

    var performRequest: (MoyaContinuation) -> Moya.Cancellable?
    var cancellable: Moya.Cancellable?

    init(_ performRequest: @escaping (MoyaContinuation) -> Moya.Cancellable?) {
        self.performRequest = performRequest
    }

    func perform(continuation: MoyaContinuation) {
        cancellable = performRequest(continuation)
    }

    func cancel() {
        cancellable?.cancel()
    }
}
