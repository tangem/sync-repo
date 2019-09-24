//
//  BTCCardBalanceOperation.swift
//  Tangem
//
//  Created by Gennady Berezovsky on 04.10.18.
//  Copyright © 2018 Smart Cash AG. All rights reserved.
//

import Foundation

enum BTCCardBalanceError: Error {
    case balanceIsNil
}

class BTCCardBalanceOperation: BaseCardBalanceOperation {

    override func handleMarketInfoLoaded(priceUSD: Double) {
        guard !isCancelled else {
            return
        }

        card.mult = priceUSD

        let operation: BlockcypherRequestOperation<BlockcypherAddressResponse> = BlockcypherRequestOperation(endpoint: .address(address: card.address), completion: { [weak self] (result) in
            switch result {
            case .success(let value):
                guard let response = value,
                let balance = response.balance
                else {
                    self?.card.mult = 0
                    self?.failOperationWith(error: BTCCardBalanceError.balanceIsNil)
                    return
                }
                
                let engine = self?.card.cardEngine as! BTCEngine
                engine.blockcypherResponse = response
                
                let satoshiBalance = Decimal(balance)
                let btcBalance =  satoshiBalance.satoshiToBtc
                
                self?.handleBalanceLoaded(balanceValue: "\(btcBalance)")
            case .failure(let error):
                self?.card.mult = 0
                self?.failOperationWith(error: error)
            }
        })
        
        operation.useTestNet =  card.isTestBlockchain
        operationQueue.addOperation(operation)
    }

    func handleBalanceLoaded(balanceValue: String) {
        guard !isCancelled else {
            return
        }
        
        card.walletValue = balanceValue

        completeOperation()
    }

}

