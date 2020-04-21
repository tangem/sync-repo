//
//  ReadIssuerDataCommand.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 19.11.2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

/// Deserialized response from the Tangem card after `ReadIssuerDataCommand`.
public struct ReadIssuerDataResponse: TlvCodable {
    /// Unique Tangem card ID number
    public let cardId: String
    /// Data defined by issuer
    public let issuerData: Data
    /**
     * Issuer’s signature of `issuerData` with `ISSUER_DATA_PRIVATE_KEY`
     * Version 1.19 and earlier:
     * Issuer’s signature of SHA256-hashed card ID concatenated with `issuerData`: SHA256(card ID | issuerData)
     * Version 1.21 and later:
     * When flag `Protect_Issuer_Data_Against_Replay` set in `SettingsMask` then signature of SHA256-hashed card ID concatenated with
     * `issuerData`  and `issuerDataCounter`: SHA256(card ID | issuerData | issuerDataCounter)
     */
    public let issuerDataSignature: Data
    /// An optional counter that protect issuer data against replay attack. When flag `Protect_Issuer_Data_Against_Replay` set in `SettingsMask`
    /// then this value is mandatory and must increase on each execution of `WriteIssuerDataCommand`.
    public let issuerDataCounter: Int?
    
    public func verify(with publicKey: Data) -> Bool? {
        return IssuerDataVerifier.verify(cardId: cardId,
                                         issuerData: issuerData,
                                         issuerDataCounter: issuerDataCounter,
                                         publicKey: publicKey,
                                         signature: issuerDataSignature)
    }
}

/**
 * This command returns 512-byte Issuer Data field and its issuer’s signature.
 * Issuer Data is never changed or parsed from within the Tangem COS. The issuer defines purpose of use,
 * format and payload of Issuer Data. For example, this field may contain information about
 * wallet balance signed by the issuer or additional issuer’s attestation data.
 */
@available(iOS 13.0, *)
public final class ReadIssuerDataCommand: Command {
    public typealias CommandResponse = ReadIssuerDataResponse
    
    private var issuerPublicKey: Data?
    
    public init(issuerPublicKey: Data? = nil) {
        self.issuerPublicKey = issuerPublicKey
    }
    
    deinit {
        print ("ReadIssuerDataCommand deinit")
    }
        
    public func run(in session: CardSession, completion: @escaping CompletionResult<ReadIssuerDataResponse>) {
        if issuerPublicKey == nil {
            issuerPublicKey = session.environment.card?.issuerPublicKey
        }
        
        guard issuerPublicKey != nil else {
            completion(.failure(.missingIssuerPublicKey))
            return
        }
        
        transieve(in: session) { result in
            switch result {
            case .success(let response):
                if let result = response.verify(with: self.issuerPublicKey!),
                    result == true {
                    completion(.success(response))
                } else {
                    completion(.failure(.verificationFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func serialize(with environment: SessionEnvironment) throws -> CommandApdu {
        let tlvBuilder = try createTlvBuilder(legacyMode: environment.legacyMode)
            .append(.pin, value: environment.pin1)
            .append(.cardId, value: environment.card?.cardId)
        
        let cApdu = CommandApdu(.readIssuerData, tlv: tlvBuilder.serialize())
        return cApdu
    }
    
    public func deserialize(with environment: SessionEnvironment, from responseApdu: ResponseApdu) throws -> ReadIssuerDataResponse {
        guard let tlv = responseApdu.getTlvData(encryptionKey: environment.encryptionKey) else {
            throw SessionError.deserializeApduFailed
        }
        
        let decoder = TlvDecoder(tlv: tlv)
        return ReadIssuerDataResponse(
            cardId: try decoder.decode(.cardId),
            issuerData: try decoder.decode(.issuerData),
            issuerDataSignature: try decoder.decode(.issuerDataSignature),
            issuerDataCounter: try decoder.decodeOptional(.issuerDataCounter))
    }
}
