//
//  SignCommand.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 03/10/2019.
//  Copyright © 2019 Tangem AG. All rights reserved.
//

import Foundation

/// Response for `SignCommand`.
public struct SignResponse {
    /// CID, Unique Tangem card ID number
    public let cardId: String
    /// Signed hashes (array of resulting signatures)
    public let signature: Data
    /// Remaining number of sign operations before the wallet will stop signing transactions.
    public let walletRemainingSignatures: Int
    /// Total number of signed single hashes returned by the card in sign command responses.
    public let walletSignedHashes: Int
}

/// Signs transaction hashes using a wallet private key, stored on the card.
@available(iOS 13.0, *)
public final class SignCommand: CommandSerializer {
    public typealias CommandResponse = SignResponse
    
    private let hashSize: Int
    private let dataToSign: Data
    private let cardId: String
    
    /// Command initializer
    /// - Parameters:
    ///   - hashes: Array of transaction hashes.
    ///   - cardId: CID, Unique Tangem card ID number
    public init(hashes: [Data], cardId: String) throws {
        guard hashes.count > 0 else {
            throw TaskError.emptyHashes
        }
        
        guard hashes.count <= 10 else {
            throw TaskError.tooMuchHashesInOneTransaction
        }
        
        hashSize = hashes.first!.count
        var flattenHashes = [Byte]()
        for hash in hashes {
            guard hash.count == hashSize else {
                throw TaskError.hashSizeMustBeEqual
            }
            
            flattenHashes.append(contentsOf: hash.toBytes)
        }
        self.cardId = cardId
        dataToSign = Data(flattenHashes)
    }
    
    public func serialize(with environment: CardEnvironment) -> CommandApdu {
        var tlvData = [Tlv(.pin, value: environment.pin1.sha256()),
                       Tlv(.pin2, value: environment.pin2.sha256()),
                       Tlv(.cardId, value: Data(hexString: cardId)),
                       Tlv(.transactionOutHashSize, value: hashSize.byte),
                       Tlv(.transactionOutHash, value: dataToSign)]
        
        /**
         * Application can optionally submit a public key Terminal_PublicKey in [SignCommand].
         * Submitted key is stored by the Tangem card if it differs from a previous submitted Terminal_PublicKey.
         * The Tangem card will not enforce security delay if [SignCommand] will be called with
         * TerminalTransactionSignature parameter containing a correct signature of raw data to be signed made with TerminalPrivateKey
         * (this key should be generated and securily stored by the application).
         */
        if let keys = environment.terminalKeys,
            let signedData = CryptoUtils().signSecp256k1(dataToSign, with: keys.privateKey) {
            tlvData.append(Tlv(.terminalTransactionSignature, value: signedData))
            tlvData.append(Tlv(.terminalPublicKey, value: keys.publicKey))
        }
        
        let cApdu = CommandApdu(.sign, tlv: tlvData, legacyMode: environment.legacyMode)
        return cApdu
    }
    
    public func deserialize(with environment: CardEnvironment, from responseApdu: ResponseApdu) throws -> SignResponse {
        guard let tlv = responseApdu.getTlvData(encryptionKey: environment.encryptionKey) else {
            throw TaskError.serializeCommandError
        }
        
        let mapper = TlvMapper(tlv: tlv)
        return SignResponse(
            cardId: try mapper.map(.cardId),
            signature: try mapper.map(.walletSignature),
            walletRemainingSignatures: try mapper.map(.walletRemainingSignatures),
            walletSignedHashes: try mapper.map(.walletSignedHashes))
    }
}
