//
//  UserPrefsService.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 03.11.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import Foundation

class UserPrefsService {
	@Storage(type: StorageType.termsOfServiceAccepted, defaultValue: false)
    var isTermsOfServiceAccepted: Bool
	
	@Storage(type: StorageType.twinCardOnboardingDisplayed, defaultValue: false)
	var isTwinCardOnboardingWasDisplayed: Bool

	@Storage(type: StorageType.numberOfAppLaunches, defaultValue: 0)
	var numberOfLaunches: Int
    
    @Storage(type: StorageType.didUserRespondToRateApp, defaultValue: false)
    var didUserRespondToRateApp: Bool
    
    @Storage(type: StorageType.dismissRateAppAtLaunch, defaultValue: nil)
    var dismissRateAppAtLaunch: Int?
    
    @Storage(type: StorageType.positiveBalanceAppearanceDate, defaultValue: nil)
    var positiveBalanceAppearanceDate: Date?
    
    @Storage(type: StorageType.positiveBalanceAppearanceLaunch, defaultValue: nil)
    var positiveBalanceAppearanceLaunch: Int?
    
    @Storage(type: StorageType.searchedCards, defaultValue: [])
    var searchedCards: [String]
    
    @Storage(type: StorageType.scannedNdefs, defaultValue: [])
    var scannedNdefs: [String]
    
    @Storage(type: StorageType.lastScannedNdef, defaultValue: "")
    var lastScannedNdef: String
    
    deinit {
        print("UserPrefsService deinit")
    }
}
