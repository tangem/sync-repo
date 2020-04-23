//
//  Config.swift
//  TangemSdk
//
//  Created by Alexander Osokin on 24.01.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

public struct Config {
    /**
     This feature forces low-level NFC communication between the Tangem card and the particular device. If it’s set to true, Tangem Card will send low-level packets to the device’s NFC chip every about 50ms. It will prevent some chip’s firmware bugs on iPhone 7/7+, when iOS is stoping NFC session due to losing the tag. Also, it will make NFC interaction slower. Change this setting only if you understand what you do.
    
     If nil, TangemSdk will turn on this feature automatically according to iPhone model
    
     Tangem card supports this setting from firmware v.2.39. Otherwise, it would be ignored.
     */
    public var legacyMode: Bool? = nil
    
    /**
     Enables or disables Linked Terminal feature. Default is **true**
     # Notes: #
     App can optionally generate ECDSA key pair Terminal_PrivateKey / Terminal_PublicKey. And then submit Terminal_PublicKey to the card in any SIGN command. Once SIGN is successfully executed by COS (Card Operation System), including PIN2 verification and/or completion of security delay, the submitted Terminal_PublicKey key is stored by COS. After that, the App instance is deemed trusted by COS and COS will allow skipping security delay for subsequent SIGN operations thus improving convenience without sacrificing security.
     
     In order to skip security delay, App should use Terminal_PrivateKey to compute the signature of the data being submitted to SIGN command for signing and transmit this signature in Terminal_Transaction_Signature parameter in the same SIGN command. COS will verify the correctness of Terminal_Transaction_Signature using previously stored Terminal_PublicKey and, if correct, will skip security delay for the current SIGN operation.
     
     If nil, TangemSdk will turn on this feature automatically according to iPhone model
     
     COS version 2.30 and later.
     */
    public var linkedTerminal: Bool? = nil
    
    
    /// If not nil, will be used to validate Issuer data and issuer extra data. If nil, issuerPublicKey from current card will be used
    public var issuerPublicKey: Data?
}



