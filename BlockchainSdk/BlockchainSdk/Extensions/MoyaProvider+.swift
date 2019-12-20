//
//  MoyaProvider+.swift
//  BlockchainSdk
//
//  Created by Alexander Osokin on 20.12.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import Moya

extension MoyaProvider {
    func requestCombine(_ target: Target) -> AnyPublisher<Response, MoyaError> {
        let future = Future<Response, MoyaError> {[unowned self] promise in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    promise(.success(response))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        return AnyPublisher(future)
    }
}
