//
//  AddCustomTokenNetworkSelectorItemView.swift
//  Tangem
//
//  Created by Andrey Chukavin on 19.09.2023.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct AddCustomTokenNetworkSelectorItemView: View {
    let viewModel: AddCustomTokenNetworkSelectorItemViewModel

    var body: some View {
        HStack(spacing: 12) {
            NetworkIcon(
                imageName: viewModel.iconName,
                isActive: false,
                isMainIndicatorVisible: false,
                size: CGSize(bothDimensions: 36)
            )

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(viewModel.networkName)
                    .lineLimit(1)
                    .layoutPriority(-1)
                    .style(Fonts.Bold.subheadline, color: Colors.Text.primary1)

                Text(viewModel.currencyCode)
                    .lineLimit(1)
                    .style(Fonts.Regular.caption1, color: Colors.Text.tertiary)
            }

            Spacer(minLength: 0)

            if viewModel.isSelected {
                Assets.check.image
                    .frame(width: 20, height: 20)
                    .foregroundColor(Colors.Icon.accent)
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.didTapWallet()
        }
    }
}

struct AddCustomTokenNetworkSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            AddCustomTokenNetworkSelectorItemView(viewModel: .init(iconName: "ethereum.fill", networkName: "Ethereum", currencyCode: "ETH", isSelected: true, didTapWallet: {}))

            AddCustomTokenNetworkSelectorItemView(viewModel: .init(iconName: "solana.fill", networkName: "Solana", currencyCode: "SOL", isSelected: false, didTapWallet: {}))

            AddCustomTokenNetworkSelectorItemView(viewModel: .init(iconName: "bsc.fill", networkName: "Binance smartest chain on the planet and maybe even the Universe", currencyCode: "BNB", isSelected: true, didTapWallet: {}))
        }
        .previewLayout(.fixed(width: 400, height: 300))
    }
}
