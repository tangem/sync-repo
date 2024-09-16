//
//  MarketsTokenDetailsMetricsView.swift
//  Tangem
//
//  Created by Andrew Son on 10/07/24.
//  Copyright © 2024 Tangem AG. All rights reserved.
//

import SwiftUI

struct MarketsTokenDetailsMetricsView: View {
    let viewModel: MarketsTokenDetailsMetricsViewModel
    let viewWidth: CGFloat

    private var itemWidth: CGFloat {
        max(0, (viewWidth - Constants.itemsSpacing - Constants.backgroundHorizontalPadding * 2) / 2)
    }

    private var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: itemWidth), spacing: Constants.itemsSpacing, alignment: .topLeading)]
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(Localization.marketsTokenDetailsMetrics)
                    .style(Fonts.Bold.footnote, color: Colors.Text.tertiary)

                Spacer()
            }

            LazyVGrid(columns: gridItems, alignment: .center, spacing: 16, content: {
                ForEach(viewModel.records.indexed(), id: \.1.id) { index, info in
                    TokenMarketsDetailsStatisticsRecordView(
                        title: info.title,
                        message: info.recordData,
                        trend: nil,
                        infoButtonAction: {
                            viewModel.showInfoBottomSheet(for: info.type)
                        }
                    )
                    .frame(minWidth: itemWidth, alignment: .leading)
                }
            })
            .drawingGroup()
        }
        .defaultRoundedBackground(with: Colors.Background.action, horizontalPadding: Constants.backgroundHorizontalPadding)
    }
}

extension MarketsTokenDetailsMetricsView {
    enum Constants {
        static let itemsSpacing: CGFloat = 12
        static let backgroundHorizontalPadding: CGFloat = 14
    }
}

extension MarketsTokenDetailsMetricsView {
    enum RecordType: String, Identifiable, MarketsTokenDetailsInfoDescriptionProvider {
        case marketCapitalization
        case marketRating
        case tradingVolume
        case fullyDilutedValuation
        case circulatingSupply
        case totalSupply

        var id: String { rawValue }

        var title: String {
            switch self {
            case .marketCapitalization: return Localization.marketsTokenDetailsMarketCapitalization
            case .marketRating: return Localization.marketsTokenDetailsMarketRating
            case .tradingVolume: return Localization.marketsTokenDetailsTradingVolume
            case .fullyDilutedValuation: return Localization.marketsTokenDetailsFullyDilutedValuation
            case .circulatingSupply: return Localization.marketsTokenDetailsCirculatingSupply
            case .totalSupply: return Localization.marketsTokenDetailsTotalSupply
            }
        }

        var infoDescription: String {
            switch self {
            case .marketCapitalization: return Localization.marketsTokenDetailsMarketCapitalizationDescription
            case .marketRating: return Localization.marketsTokenDetailsMarketRatingDescription
            case .tradingVolume: return Localization.marketsTokenDetailsTradingVolume24hDescription
            case .fullyDilutedValuation: return Localization.marketsTokenDetailsFullyDilutedValuationDescription
            case .circulatingSupply: return Localization.marketsTokenDetailsCirculatingSupplyDescription
            case .totalSupply: return Localization.marketsTokenDetailsTotalSupplyDescription
            }
        }
    }

    struct RecordInfo: Identifiable {
        let type: RecordType
        let recordData: String

        var id: String {
            "\(type.id) - \(recordData)"
        }

        var title: String {
            type.title
        }
    }
}

#Preview {
    MarketsTokenDetailsMetricsView(
        viewModel: .init(
            metrics: .init(
                marketRating: 3,
                circulatingSupply: 112259808785.143,
                marketCap: 112234033891,
                volume24H: 42854017104,
                totalSupply: 112286364258.112,
                fullyDilutedValuation: 112234033891
            ),
            notationFormatter: .init(),
            cryptoCurrencyCode: "USDT",
            infoRouter: nil
        ),
        viewWidth: 300
    )
}
