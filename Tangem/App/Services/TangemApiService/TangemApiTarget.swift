//
//  TangemApiTarget.swift
//  Tangem
//
//  Created by Andrey Chukavin on 29.03.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import Foundation
import Moya
import TangemNetworkUtils

struct TangemApiTarget: TargetType {
    let type: TargetType
    let authData: AuthData?

    // MARK: - TargetType

    var baseURL: URL {
        switch type {
        case .rawData(let fullURL):
            fullURL
        default:
            AppEnvironment.current.apiBaseUrl
        }
    }

    var path: String {
        switch type {
        case .rawData:
            return ""
        case .currencies:
            return "/currencies"
        case .coins:
            return "/coins"
        case .quotes:
            return "/quotes"
        case .geo:
            return "/geo"
        case .features:
            return "/features"
        case .getUserWalletTokens(let key), .saveUserWalletTokens(let key, _):
            return "/user-tokens/\(key)"
        case .loadReferralProgramInfo(let userWalletId, _):
            return "/referral/\(userWalletId)"
        case .participateInReferralProgram:
            return "/referral"
        case .promotion:
            return "/promotion"
        case .validateNewUserPromotionEligibility:
            return "/promotion/code/validate"
        case .validateOldUserPromotionEligibility:
            return "/promotion/validate"
        case .awardNewUser:
            return "/promotion/code/award"
        case .awardOldUser:
            return "/promotion/award"
        case .resetAward:
            return "/private/manual-check/promotion-award"
        case .createAccount:
            return "/user-network-account"
        case .apiList:
            return "/networks/providers"
        case .story(let storyId):
            return "/stories/\(storyId)"

        // MARK: - Markets paths
        case .coinsList:
            return "/coins/list"
        case .coinsHistoryChartPreview:
            return "/coins/history_preview"
        case .tokenMarketsDetails(let requestModel):
            return "/coins/\(requestModel.tokenId)"
        case .historyChart(let requestModel):
            return "/coins/\(requestModel.tokenId)/history"
        case .tokenExchangesList(let requestModel):
            return "/coins/\(requestModel.tokenId)/exchanges"

        // MARK: - Action Buttons
        case .hotCrypto:
            return "/hot_crypto"

        // MARK: SeedNotify
        case .seedNotifyGetStatus(let userWalletId), .seedNotifySetStatus(let userWalletId, _):
            return "/seedphrase-notification/\(userWalletId)"
        case .seedNotifyGetStatusConfirmed(let userWalletId), .seedNotifySetStatusConfirmed(let userWalletId, _):
            return "/seedphrase-notification/\(userWalletId)/confirmed"
        case .walletInitialized:
            return "/user-tokens"
        }
    }

    var method: Moya.Method {
        switch type {
        case .rawData,
             .currencies,
             .coins,
             .quotes,
             .geo,
             .getUserWalletTokens,
             .loadReferralProgramInfo,
             .promotion,
             .apiList,
             .features,
             .coinsList,
             .coinsHistoryChartPreview,
             .tokenMarketsDetails,
             .historyChart,
             .tokenExchangesList,
             .hotCrypto,
             .seedNotifyGetStatus,
             .seedNotifyGetStatusConfirmed,
             .story:
            return .get
        case .saveUserWalletTokens,
             .seedNotifySetStatus,
             .seedNotifySetStatusConfirmed:
            return .put
        case .participateInReferralProgram,
             .validateNewUserPromotionEligibility,
             .validateOldUserPromotionEligibility,
             .awardNewUser,
             .awardOldUser,
             .createAccount,
             .walletInitialized:
            return .post
        case .resetAward:
            return .delete
        }
    }

    var task: Task {
        switch type {
        case .rawData:
            return .requestPlain
        case .coins(let pageModel):
            return .requestParameters(pageModel)
        case .quotes(let pageModel):
            return .requestParameters(pageModel)
        case .currencies, .geo, .features, .getUserWalletTokens:
            return .requestPlain
        case .saveUserWalletTokens(_, let list):
            return .requestJSONEncodable(list)
        case .loadReferralProgramInfo(_, let expectedAwardsLimit):
            return .requestParameters(
                parameters: [
                    "expected-awards-limit": expectedAwardsLimit,
                ],
                encoding: URLEncoding.default
            )
        case .participateInReferralProgram(let requestData):
            return .requestParameters(requestData)
        case .promotion(let request):
            return .requestParameters(request)
        case .validateNewUserPromotionEligibility(let walletId, let code):
            return .requestParameters(parameters: [
                "walletId": walletId,
                "code": code,
            ], encoding: JSONEncoding.default)
        case .validateOldUserPromotionEligibility(let walletId, let programName):
            return .requestParameters(parameters: [
                "walletId": walletId,
                "programName": programName,
            ], encoding: JSONEncoding.default)
        case .awardNewUser(let walletId, let address, let code):
            return .requestParameters(parameters: [
                "walletId": walletId,
                "address": address,
                "code": code,
            ], encoding: JSONEncoding.default)
        case .awardOldUser(let walletId, let address, let programName):
            return .requestParameters(parameters: [
                "walletId": walletId,
                "address": address,
                "programName": programName,
            ], encoding: JSONEncoding.default)
        case .resetAward(let cardId):
            return .requestParameters(parameters: [
                "cardId": cardId,
            ], encoding: URLEncoding.default)
        case .createAccount(let parameters):
            return .requestJSONEncodable(parameters)
        case .apiList:
            return .requestPlain
        case .story:
            return .requestPlain

        // MARK: - Markets tasks
        case .coinsList(let requestData):
            return .requestParameters(parameters: requestData.parameters, encoding: URLEncoding.default)
        case .coinsHistoryChartPreview(let requestData):
            return .requestParameters(parameters: requestData.parameters, encoding: URLEncoding(destination: .queryString, arrayEncoding: .noBrackets))
        case .tokenMarketsDetails(let requestModel):
            return .requestParameters(parameters: [
                "currency": requestModel.currency,
                "language": requestModel.language,
            ], encoding: URLEncoding.default)
        case .historyChart(let requestModel):
            return .requestParameters(
                parameters: [
                    "currency": requestModel.currency,
                    "interval": requestModel.interval.historyChartId,
                ],
                encoding: URLEncoding.default
            )
        case .seedNotifySetStatus(_, let status), .seedNotifySetStatusConfirmed(_, let status):
            let requestModel = SeedNotifyDTO(status: status)
            return .requestParameters(requestModel, encoding: URLEncoding.default)
        case .tokenExchangesList, .seedNotifyGetStatus, .seedNotifyGetStatusConfirmed:
            return .requestPlain
        case .hotCrypto(let requestModel):
            return .requestParameters(parameters: ["currency": requestModel.currency], encoding: URLEncoding.default)
        case .walletInitialized(let userWalletId):
            return .requestParameters(
                parameters: [
                    "user_wallet_id": userWalletId,
                ],
                encoding: URLEncoding.default
            )
        }
    }

    var headers: [String: String]? {
        if case .rawData = type {
            return nil
        }

        var headers: [String: String] = [:]

        if let authData {
            headers["card_id"] = authData.cardId
            headers["card_public_key"] = authData.cardPublicKey.hexString
        }

        return headers
    }
}

extension TangemApiTarget {
    enum TargetType {
        /// Used to fetch binary data (images, documents, etc.) from a given `URL`.
        case rawData(url: URL)

        case currencies
        case coins(_ requestModel: CoinsList.Request)
        case quotes(_ requestModel: QuotesDTO.Request)
        case geo
        case features
        case getUserWalletTokens(key: String)
        case saveUserWalletTokens(key: String, list: UserTokenList)
        case loadReferralProgramInfo(userWalletId: String, expectedAwardsLimit: Int)
        case participateInReferralProgram(userInfo: ReferralParticipationRequestBody)
        case createAccount(_ parameters: BlockchainAccountCreateParameters)

        // Promotion
        case promotion(request: ExpressPromotion.Request)
        case validateNewUserPromotionEligibility(walletId: String, code: String)
        case validateOldUserPromotionEligibility(walletId: String, programName: String)
        case awardNewUser(walletId: String, address: String, code: String)
        case awardOldUser(walletId: String, address: String, programName: String)
        case resetAward(cardId: String)

        case story(_ id: String)

        // MARK: - Markets Targets

        case coinsList(_ requestModel: MarketsDTO.General.Request)
        case coinsHistoryChartPreview(_ requestModel: MarketsDTO.ChartsHistory.PreviewRequest)
        case tokenMarketsDetails(_ requestModel: MarketsDTO.Coins.Request)
        case historyChart(_ requestModel: MarketsDTO.ChartsHistory.HistoryRequest)
        case tokenExchangesList(_ requestModel: MarketsDTO.ExchangesList.Request)

        // MARK: - Action Buttons

        case hotCrypto(_ requestModel: HotCryptoDTO.Request)

        /// Configs
        case apiList

        // Seed notification
        case seedNotifyGetStatus(userWalletId: String)
        case seedNotifySetStatus(userWalletId: String, status: SeedNotifyStatus)
        case seedNotifyGetStatusConfirmed(userWalletId: String)
        case seedNotifySetStatusConfirmed(userWalletId: String, status: SeedNotifyStatus)
        case walletInitialized(userWalletId: String)
    }

    struct AuthData {
        let cardId: String
        let cardPublicKey: Data
    }
}

extension TangemApiTarget: CachePolicyProvider {
    var cachePolicy: URLRequest.CachePolicy {
        switch type {
        case .geo, .features, .apiList, .quotes, .coinsList, .tokenMarketsDetails:
            return .reloadIgnoringLocalAndRemoteCacheData
        default:
            return .useProtocolCachePolicy
        }
    }
}

extension TangemApiTarget: TargetTypeLogConvertible {
    var requestDescription: String {
        path
    }

    var shouldLogResponseBody: Bool {
        switch type {
        case .currencies, .coins, .quotes, .apiList, .coinsList, .coinsHistoryChartPreview,
             .historyChart, .tokenMarketsDetails, .tokenExchangesList, .story, .rawData, .hotCrypto:
            return false
        case .geo, .features, .getUserWalletTokens, .saveUserWalletTokens, .loadReferralProgramInfo, .participateInReferralProgram, .createAccount, .promotion, .validateNewUserPromotionEligibility, .validateOldUserPromotionEligibility, .awardNewUser, .awardOldUser, .resetAward, .seedNotifyGetStatus, .seedNotifySetStatus, .seedNotifyGetStatusConfirmed, .seedNotifySetStatusConfirmed, .walletInitialized:
            return true
        }
    }
}
