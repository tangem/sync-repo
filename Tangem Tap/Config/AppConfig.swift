//
//  AppConfig.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 01.09.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig
import BlockchainSdk

struct AppConfig {
    var coinMarketCapApiKey: String {
		keysManager.keys.coinMarketCapKey
    }
    
    var moonPayApiKey: String {
		keysManager.keys.moonPayApiKey
    }
    
    var moonPaySecretApiKey: String {
		keysManager.keys.moonPayApiSecretKey
    }
    
    var isEnableMoonPay: Bool {
		remoteConfig.features.isTopUpEnabled
    }
    
    var isWalletPayIdEnabled: Bool {
		remoteConfig.features.isWalletPayIdEnabled
	}
	
	var isSendingToPayIdEnabled: Bool {
		remoteConfig.features.isSendingToPayIdEnabled
	}
	
	var isEnableTwinCreation: Bool {
		remoteConfig.features.isCreatingTwinCardsAllowed
	}
	
	var blockchainConfig: BlockchainSdkConfig {
		BlockchainSdkConfig(blockchairApiKey: keysManager.keys.blockchairApiKey,
							blockcypherTokens: keysManager.keys.blockcypherTokens,
							infuraProjectId: keysManager.keys.infuraProjectId)
	}
	
	private let remoteConfig = RemoteConfigManager()
	private let keysManager: KeysManager!
    
    init() {
		keysManager = try? KeysManager()
    }
}
