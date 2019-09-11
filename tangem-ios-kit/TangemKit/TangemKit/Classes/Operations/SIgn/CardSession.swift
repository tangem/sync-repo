//
//  CardSignOperation.swift
//  TangemKit
//
//  Created by Alexander Osokin on 09/07/2019.
//

import Foundation
#if canImport(CoreNFC)
import CoreNFC
#endif

@available(iOS 13.0, *)
public enum CardSessionResult<T> {
    case success(T)
    case failure(Error)
}

@available(iOS 13.0, *)
public class CardSession: NSObject {
    
    private let completion: (CardSessionResult<[CardTag : CardTLV]>) -> Void
    private var readerSession: NFCTagReaderSession?
    private var cardHandled: Bool = false
    public private(set) var isBusy: Bool = false
    
    public init(completion: @escaping (CardSessionResult<[CardTag : CardTLV]>) -> Void) {
        self.completion = completion
    }
    
    public func start() {
        isBusy = true
        readerSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)!
        readerSession!.alertMessage = "Hold your iPhone near a Tangem card"
        readerSession!.begin()
    }
    
    private func buildReadApdu() -> NFCISO7816APDU {
        let tlvData = [CardTLV(.pin, value: "000000".sha256().asciiHexToData())]
        let commandApdu = CommandApdu(with: .read, tlv: tlvData)
        let signApduBytes = commandApdu.buildCommand()
        let apdu = NFCISO7816APDU(data: Data(bytes: signApduBytes))!
        return apdu
    }
    
    private func buildCheckWalletApdu(with challenge: [UInt8], cardId: [UInt8]) -> NFCISO7816APDU {
        let tlvData = [CardTLV(.pin, value: "000000".sha256().asciiHexToData()),
                       CardTLV(.cardId, value: cardId),
                       CardTLV(.challenge, value: challenge)]
        let commandApdu = CommandApdu(with: .checkWallet, tlv: tlvData)
        let signApduBytes = commandApdu.buildCommand()
        let apdu = NFCISO7816APDU(data: Data(bytes: signApduBytes))!
        return apdu
    }
    
    private func verifyWallet(readResult: [CardTag : CardTLV],
                              checkWalletResult: [CardTag : CardTLV],
                              challenge: [UInt8]) -> Bool {
        
        guard let curveId = readResult[.curveId]?.value?.utf8String,
            let curve = Curve(rawValue: curveId),
            let publicKey = readResult[.walletPublicKey]?.value,
            let salt = checkWalletResult[.salt]?.value,
            let signature = checkWalletResult[.signature]?.value else {
                return false
        }
        let data = challenge + salt
        
        switch curve {
        case .secp256k1:
            let message = data.sha256()
            var vrfy: secp256k1_context = secp256k1_context_create(.SECP256K1_CONTEXT_VERIFY)!
            var sig = secp256k1_ecdsa_signature()
            var dummy = secp256k1_ecdsa_signature()
            _ = secp256k1_ecdsa_signature_parse_compact(vrfy, &sig, signature)
            _ = secp256k1_ecdsa_signature_normalize(vrfy, &dummy, sig)
            var pubkey = secp256k1_pubkey()
            _ = secp256k1_ec_pubkey_parse(vrfy, &pubkey, publicKey, 65)
             let result = secp256k1_ecdsa_verify(vrfy, dummy, message, pubkey)
            secp256k1_context_destroy(&vrfy)
            return result
        case .ed25519:
            let message = data.sha512()
            let result = Ed25519.verify(signature, message, publicKey)
            return result
        }
    }
    
    private func sendCardRequest(to tag7816: NFCISO7816Tag,
                                 apdu: NFCISO7816APDU,
                                 session: NFCTagReaderSession,
                                 completionHandler:  @escaping (CardSessionResult<[CardTag : CardTLV]>) -> Void) {
        tag7816.sendCommand(apdu: apdu) {(data, sw1, sw2, apduError) in
            guard apduError == nil else {
                completionHandler(.failure("Request failed"))
                return
            }
            
            let respApdu = ResponseApdu(with: data, sw1: sw1, sw2: sw2)
            if let cardState = respApdu.state {
                switch cardState {
                case .processCompleted:
                    completionHandler(.success(respApdu.tlv))
                default:
                    session.invalidate(errorMessage: cardState.localizedDescription)
                    completionHandler(.failure("Request failed"))
                }
            } else {
                session.invalidate(errorMessage: "Unknown card state: \(sw1) \(sw2)")
                completionHandler(.failure("Request failed"))
            }
        }
    }
}


@available(iOS 13.0, *)
extension CardSession: NFCTagReaderSessionDelegate {
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("CardSession active")
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        guard !cardHandled else {
            return
        }
        
        self.isBusy = false
        
        guard let nfcError = error as? NFCReaderError,
            nfcError.code != .readerSessionInvalidationErrorUserCanceled else {
                completion(.failure(error))
                return
        }
        
        completion(.failure(error))
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if case let .iso7816(tag7816) = tags.first {
            let nfcTag = tags.first!
            session.connect(to: nfcTag) {[unowned self] error in
                guard error == nil else {
                    session.invalidate(errorMessage: error!.localizedDescription)
                    return
                }
                
                let readApdu = self.buildReadApdu()
                guard let challenge = CryptoUtils.getRandomBytes(count: 16) else {
                    let error = "Failed to generate challenge"
                    session.invalidate(errorMessage: error)
                    self.isBusy = false
                    self.completion(.failure(error))
                    return
                }
                
                self.sendCardRequest(to: tag7816, apdu: readApdu, session: session) { result in
                    switch result {
                    case .success(let readResult):
                        
                        let cardId = readResult[.cardId]?.value
                        let checkWalletApdu = self.buildCheckWalletApdu(with: challenge, cardId: cardId! )
                        
                        self.sendCardRequest(to: tag7816, apdu: checkWalletApdu, session: session) {[unowned self] result in
                            switch result {
                            case .success(let checkWalletResult):
                                self.cardHandled = true
                                session.invalidate()
                                let verifyed = self.verifyWallet(readResult: readResult, checkWalletResult: checkWalletResult, challenge: challenge)
                                self.isBusy = false
                                if verifyed {
                                    self.completion(.success(readResult))
                                } else {
                                    self.completion(.failure("Card verification failed"))
                                }
                                break
                            default:
                                break
                            }
                        }
                        break
                    default:
                        break
                    }
                }
            }
        }
    }
    
}
