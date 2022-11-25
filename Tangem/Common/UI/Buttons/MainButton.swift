//
//  MainButton.swift
//  Tangem
//
//  Created by Sergey Balashov on 30.10.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct MainButton: View {
    private let text: String
    private let icon: Icon?
    private let style: Style
    private let isLoading: Bool
    private let isDisabled: Bool
    private let action: () -> Void

    init(
        text: String,
        icon: Icon? = nil,
        style: Style = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping (() -> Void)
    ) {
        self.text = text
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    init(settings: Settings) {
        self.init(
            text: settings.text,
            icon: settings.icon,
            style: settings.style,
            isLoading: settings.isLoading,
            isDisabled: settings.isDisabled,
            action: settings.action
        )
    }

    var body: some View {
        Button(action: action) {
            content
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 14)
                .background(style.background(isDisabled: isDisabled))
                .cornerRadius(14)
                .contentShape(Rectangle())
        }
        .disabled(isDisabled)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading {
            loader
        } else {
            switch icon {
            case .none:
                textView

            case let .leading(icon):
                HStack(alignment: .center, spacing: 10) {
                    iconView(icon: icon)

                    textView
                }
            case let .trailing(icon):
                HStack(alignment: .center, spacing: 10) {
                    textView

                    iconView(icon: icon)
                }
            }
        }
    }

    @ViewBuilder
    private var loader: some View {
        if #available(iOS 14.0, *) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: style.loaderColor()))
        } else {
            ActivityIndicatorView(color: style.loaderColor().uiColor())
        }
    }

    @ViewBuilder
    private var textView: some View {
        Text(text)
            .style(Fonts.Bold.callout,
                   color: style.textColor(isDisabled: isDisabled))
    }

    @ViewBuilder
    private func iconView(icon: Image) -> some View {
        icon
            .resizable()
            .renderingMode(.template)
            .frame(width: 20, height: 20)
            .foregroundColor(style.iconColor(isDisabled: isDisabled))
    }
}

extension MainButton {
    enum Icon {
        case leading(_ icon: Image)
        case trailing(_ icon: Image)
    }

    enum Style: String, Hashable, CaseIterable {
        case primary
        case secondary

        func iconColor(isDisabled: Bool) -> Color {
            if isDisabled {
                return Colors.Icon.inactive
            }

            switch self {
            case .primary:
                return Colors.Icon.primary2
            case .secondary:
                return Colors.Icon.primary1
            }
        }

        func textColor(isDisabled: Bool) -> Color {
            if isDisabled {
                return Colors.Text.disabled
            }

            switch self {
            case .primary:
                return Colors.Text.primary2
            case .secondary:
                return Colors.Text.primary1
            }
        }

        func loaderColor() -> Color {
            switch self {
            case .primary:
                return Colors.Text.primary2
            case .secondary:
                return Colors.Text.primary1
            }
        }

        func background(isDisabled: Bool) -> Color {
            if isDisabled {
                return Colors.Button.disabled
            }

            switch self {
            case .primary:
                return Colors.Button.primary
            case .secondary:
                return Colors.Button.secondary
            }
        }
    }

    struct Settings {
        let text: String
        let icon: Icon?
        let style: Style
        let isLoading: Bool
        let isDisabled: Bool
        let action: () -> Void

        init(
            text: String,
            icon: Icon? = nil,
            style: Style = .primary,
            isLoading: Bool = false,
            isDisabled: Bool = false,
            action: @escaping (() -> Void)
        ) {
            self.text = text
            self.icon = icon
            self.style = style
            self.isLoading = isLoading
            self.isDisabled = isDisabled
            self.action = action
        }
    }
}

struct MainButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ForEach(MainButton.Style.allCases, id: \.hashValue) { style in
                buttons(style: style)
                    .previewDisplayName(style.rawValue)
            }
        }
        .previewLayout(.sizeThatFits)
    }

    @ViewBuilder
    static func buttons(style: MainButton.Style) -> some View {
        VStack(spacing: 16) {
            MainButton(text: "Order card",
                       icon: .leading(Assets.tangemIcon),
                       style: style) {}

            MainButton(text: "Order card",
                       icon: .leading(Assets.tangemIcon),
                       style: style,
                       isDisabled: true) {}

            MainButton(text: "Order card",
                       icon: .trailing(Assets.tangemIcon),
                       style: style) {}

            MainButton(text: "Order card",
                       icon: .trailing(Assets.tangemIcon),
                       style: style,
                       isDisabled: true) {}

            MainButton(text: "Order card",
                       icon: .trailing(Assets.tangemIcon),
                       style: style,
                       isLoading: true) {}
        }
        .padding(.horizontal, 16)
    }
}
