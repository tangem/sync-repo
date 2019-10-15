//
//  Task.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 02/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation
import CoreNFC

public enum TaskError: Error, LocalizedError {
    case unknownStatus(sw: UInt16)
    case mappingError
    case errorProcessingCommand
    case invalidState
    case insNotSupported
    case vefificationFailed
    case cardError
    case nfcUnavailable
    case readerError(NFCReaderError)
    
    public var localizedDescription: String {
        switch self {
        case .readerError(let nfcError):
            return nfcError.localizedDescription
        default:
             return "\(self)"
        }
    }
}

@available(iOS 13.0, *)
open class Task<TaskResult> {
    var cardReader: CardReader!
    var delegate: CardManagerDelegate?

    public final func run(with environment: CardEnvironment, completion: @escaping (TaskResult, CardEnvironment) -> Void) {
        guard cardReader != nil else {
            fatalError("Card reader is nil")
        }
        
        cardReader.startSession()
        onRun(environment: environment, completion: completion)
    }
    
    public func onRun(environment: CardEnvironment, completion: @escaping (TaskResult, CardEnvironment) -> Void) {
        
    }
    
    func sendCommand<T: CommandSerializer>(_ commandSerializer: T, environment: CardEnvironment, completion: @escaping (CompletionResult<T.CommandResponse, TaskError>, CardEnvironment) -> Void) {
            let commandApdu = commandSerializer.serialize(with: environment)
            cardReader.send(commandApdu: commandApdu) { [weak self] commandResponse in
                guard let self = self else { return }
                
                switch commandResponse {
                case .success(let responseApdu):
                    guard let status = responseApdu.status else {
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.unknownStatus(sw: responseApdu.sw)), environment)
                        }
                        return
                    }
                    
                    switch status {
                    case .needPause:
                        
                        //TODO: handle security delay
                        break
                    case .needEcryption:
                        //TODO: handle needEcryption
                        break
                    case .invalidParams:
                        //TODO: handle need pin ?
                        //            if let newEnvironment = returnedEnvironment {
                        //                self?.cardEnvironmentRepository.cardEnvironment = newEnvironment
                        //            }
                        
                        break
                    case .processCompleted, .pin1Changed, .pin2Changed, .pin3Changed, .pinsNotChanged:
                        if let responseData = commandSerializer.deserialize(with: environment, from: responseApdu) {
                            DispatchQueue.main.async {
                                completion(.success(responseData), environment)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(.failure(TaskError.mappingError), environment)
                            }
                        }
                    case .errorProcessingCommand:
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.errorProcessingCommand), environment)
                        }
                    case .invalidState:
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.invalidState), environment)
                        }
                    case .insNotSupported:
                        DispatchQueue.main.async {
                            completion(.failure(TaskError.insNotSupported), environment)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(.readerError(error)), environment)
                    }
                }
            }
    }
}
