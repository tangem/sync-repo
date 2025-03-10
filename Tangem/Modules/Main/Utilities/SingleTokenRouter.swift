//
//  SingleTokenNavigationRouter.swift
//  Tangem
//
//  Created by Andrew Son on 07/09/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import Foundation
import Combine
import BlockchainSdk
import TangemExpress

protocol SingleTokenRoutable {
    func openReceive(walletModel: WalletModel)
    func openBuy(walletModel: WalletModel)
    func openSend(walletModel: WalletModel)
    func openExchange(walletModel: WalletModel)
    func openStaking(walletModel: WalletModel)
    func openSell(for walletModel: WalletModel)
    func openSendToSell(with request: SellCryptoRequest, for walletModel: WalletModel)
    func openExplorer(at url: URL, for walletModel: WalletModel)
    func openMarketsTokenDetails(for tokenItem: TokenItem)
    func openInSafari(url: URL)
    func openOnramp(walletModel: WalletModel)
    func openPendingExpressTransactionDetails(
        pendingTransaction: PendingTransaction,
        tokenItem: TokenItem,
        pendingTransactionsManager: PendingExpressTransactionsManager
    )
}

final class SingleTokenRouter: SingleTokenRoutable {
    @Injected(\.keysManager) private var keysManager: KeysManager
    @Injected(\.quotesRepository) private var quotesRepository: TokenQuotesRepository

    private let userWalletModel: UserWalletModel
    private weak var coordinator: SingleTokenBaseRoutable?

    init(userWalletModel: UserWalletModel, coordinator: SingleTokenBaseRoutable?) {
        self.userWalletModel = userWalletModel
        self.coordinator = coordinator
    }

    func openReceive(walletModel: WalletModel) {
        let infos = walletModel.wallet.addresses.map { address in
            ReceiveAddressInfo(
                address: address.value,
                type: address.type,
                localizedName: address.localizedName,
                addressQRImage: QrCodeGenerator.generateQRCode(from: address.value)
            )
        }
        coordinator?.openReceiveScreen(
            tokenItem: walletModel.tokenItem,
            addressInfos: infos
        )
    }

    func openBuy(walletModel: WalletModel) {
        assert(!FeatureProvider.isAvailable(.onramp), "Use open openOnramp(for:) instead")

        let exchangeUtility = buildExchangeCryptoUtility(for: walletModel)

        guard let url = exchangeUtility.buyURL else { return }

        coordinator?.openBuyCrypto(at: url) { [weak self] in
            self?.sendAnalyticsEvent(.tokenBought, for: walletModel)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                walletModel.update(silent: true)
            }
        }
    }

    func openOnramp(walletModel: WalletModel) {
        coordinator?.openOnramp(walletModel: walletModel, userWalletModel: userWalletModel)
    }

    func openSend(walletModel: WalletModel) {
        coordinator?.openSend(
            userWalletModel: userWalletModel,
            walletModel: walletModel
        )
    }

    func openExchange(walletModel: WalletModel) {
        let input = CommonExpressModulesFactory.InputModel(userWalletModel: userWalletModel, initialWalletModel: walletModel)
        coordinator?.openExpress(input: input)
    }

    func openStaking(walletModel: WalletModel) {
        sendAnalyticsEvent(.stakingClicked, for: walletModel)
        guard let stakingManager = walletModel.stakingManager else {
            return
        }

        coordinator?.openStaking(
            options: .init(
                userWalletModel: userWalletModel,
                walletModel: walletModel,
                manager: stakingManager
            )
        )
    }

    func openSell(for walletModel: WalletModel) {
        let exchangeUtility = buildExchangeCryptoUtility(for: walletModel)
        guard let url = exchangeUtility.sellURL else {
            return
        }

        coordinator?.openSellCrypto(at: url) { [weak self] response in
            if let request = exchangeUtility.extractSellCryptoRequest(from: response) {
                self?.openSendToSell(with: request, for: walletModel)
            }
        }
    }

    func openSendToSell(with request: SellCryptoRequest, for walletModel: WalletModel) {
        // TODO: Refactor with Send screen navigation
        guard var amountToSend = walletModel.wallet.amounts[walletModel.amountType] else {
            return
        }

        amountToSend.value = request.amount
        coordinator?.openSendToSell(
            amountToSend: amountToSend,
            destination: request.targetAddress,
            tag: request.tag,
            userWalletModel: userWalletModel,
            walletModel: walletModel
        )
    }

    func openExplorer(at url: URL, for walletModel: WalletModel) {
        sendAnalyticsEvent(.buttonExplore, for: walletModel)
        coordinator?.openInSafari(url: url)
    }

    func openMarketsTokenDetails(for tokenItem: TokenItem) {
        guard let tokenId = getTokenItemId(for: tokenItem) else {
            return
        }

        let quoteData = quotesRepository.quote(for: tokenId)
        let model = MarketsTokenModel(
            id: tokenId,
            name: tokenItem.name,
            symbol: tokenItem.currencySymbol,
            currentPrice: quoteData?.price,
            priceChangePercentage: MarketsTokenQuoteHelper().makePriceChangeIntervalsDictionary(from: quoteData) ?? [:],
            marketRating: nil,
            marketCap: nil,
            isUnderMarketCapLimit: nil
        )

        coordinator?.openMarketsTokenDetails(tokenModel: model)
    }

    func openInSafari(url: URL) {
        coordinator?.openInSafari(url: url)
    }

    func openPendingExpressTransactionDetails(pendingTransaction: PendingTransaction, tokenItem: TokenItem, pendingTransactionsManager: any PendingExpressTransactionsManager) {
        coordinator?.openPendingExpressTransactionDetails(
            pendingTransaction: pendingTransaction,
            tokenItem: tokenItem,
            userWalletModel: userWalletModel,
            pendingTransactionsManager: pendingTransactionsManager
        )
    }

    private func getTokenItemId(for tokenItem: TokenItem) -> TokenItemId? {
        guard tokenItem.isBlockchain, tokenItem.blockchain.isL2EthereumNetwork else {
            return tokenItem.id
        }

        return Blockchain.ethereum(testnet: false).coinId
    }
}

// MARK: - Utilities functions

extension SingleTokenRouter {
    private func sendAnalyticsEvent(_ event: Analytics.Event, for walletModel: WalletModel) {
        Analytics.log(event: event, params: [.token: walletModel.tokenItem.currencySymbol])
    }

    private func buildExchangeCryptoUtility(for walletModel: WalletModel) -> ExchangeCryptoUtility {
        return ExchangeCryptoUtility(
            blockchain: walletModel.blockchainNetwork.blockchain,
            address: walletModel.defaultAddress,
            amountType: walletModel.amountType
        )
    }
}
