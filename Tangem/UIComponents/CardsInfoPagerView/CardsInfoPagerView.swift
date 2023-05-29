//
//  EnvironmentValues+CardsInfoPagerView.swift
//  Tangem
//
//  Created by Andrey Fedorov on 24/05/23.
//  Copyright © 2023 Tangem AG. All rights reserved.
//

import SwiftUI

struct CardsInfoPagerView<
    Data, ID, Header, Body
>: View where Data: RandomAccessCollection, ID: Hashable, Header: View, Body: View, Data.Index == Int {
    typealias HeaderFactory = (_ element: Data.Element) -> Header
    typealias ContentFactory = (_ element: Data.Element) -> Body

    private enum Constants {
        static var contentViewVerticalOffset: CGFloat { 44.0 }
        static var pageSwitchThreshold: CGFloat { 0.5 }
        static var pageSwitchAnimation: Animation { .interactiveSpring(response: 0.30) }
    }

    private let data: Data
    private let idProvider: KeyPath<Data.Element, ID>
    private let headerFactory: HeaderFactory
    private let contentFactory: ContentFactory

    @Binding private var selectedIndex: Int

    @GestureState private var nextIndexToSelect: Int?

    @GestureState private var hasNextIndexToSelect = true

    @GestureState private var horizontalTranslation: CGFloat = .zero

    /// - Warning: Won't be reset back to 0 after successful (non-cancelled) page switch, use with caution.
    @State private var pageSwitchProgress: CGFloat = .zero

    private var contentViewVerticalOffset: CGFloat = Constants.contentViewVerticalOffset

    private var pageSwitchThreshold: CGFloat = Constants.pageSwitchThreshold

    private var pageSwitchAnimation: Animation = Constants.pageSwitchAnimation

    private var lowerBound: Int { 0 }
    private var upperBound: Int { data.count - 1 }

    init(
        data: Data,
        id idProvider: KeyPath<Data.Element, ID>,
        selectedIndex: Binding<Int>,
        @ViewBuilder headerFactory: @escaping HeaderFactory,
        @ViewBuilder contentFactory: @escaping ContentFactory
    ) {
        self.data = data
        self.idProvider = idProvider
        _selectedIndex = selectedIndex
        self.headerFactory = headerFactory
        self.contentFactory = contentFactory
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 0.0) {
                HStack(spacing: 0.0) {
                    ForEach(data, id: idProvider) { element in
                        headerFactory(element)
                            .frame(width: proxy.size.width)
                    }
                }
                .layoutPriority(1.0)
                .offset(x: horizontalTranslation - CGFloat(selectedIndex) * proxy.size.width)

                contentFactory(data[nextIndexToSelect ?? selectedIndex])
                    .modifier(
                        BodyAnimationModifier(
                            progress: pageSwitchProgress,
                            verticalOffset: contentViewVerticalOffset,
                            hasNextIndexToSelect: hasNextIndexToSelect
                        )
                    )
                    .frame(width: proxy.size.width)
            }
            .animation(pageSwitchAnimation, value: horizontalTranslation)
            .gesture(makeDragGesture(with: proxy))
        }
        .edgesIgnoringSafeArea(.bottom)
    }

    private func makeDragGesture(with proxy: GeometryProxy) -> some Gesture {
        DragGesture()
            .updating($horizontalTranslation) { value, state, _ in
                state = value.translation.width
            }
            .updating($nextIndexToSelect) { value, state, _ in
                state = nextIndexToSelectFiltered(
                    translation: value.translation.width,
                    totalWidth: proxy.size.width
                )
            }
            .updating($hasNextIndexToSelect) { value, state, _ in
                state = nextIndexToSelectFiltered(
                    translation: value.translation.width,
                    totalWidth: proxy.size.width
                ) != nil
            }
            .onChanged { value in
                pageSwitchProgress = abs(value.translation.width / proxy.size.width)
            }
            .onEnded { value in
                let newIndex = nextIndexToSelectClamped(
                    translation: value.translation.width,
                    totalWidth: proxy.size.width
                )
                pageSwitchProgress = newIndex == selectedIndex ? 0.0 : 1.0
                selectedIndex = newIndex
            }
    }

    private func nextIndexToSelectClamped(translation: CGFloat, totalWidth: CGFloat) -> Int {
        let nextIndex = nextIndexToSelect(translation: translation, totalWidth: totalWidth)
        return clamp(nextIndex, min: lowerBound, max: upperBound)
    }

    private func nextIndexToSelectFiltered(translation: CGFloat, totalWidth: CGFloat) -> Int? {
        let nextIndex = nextIndexToSelect(translation: translation, totalWidth: totalWidth)
        return lowerBound ... upperBound ~= nextIndex ? nextIndex : nil
    }

    private func nextIndexToSelect(translation: CGFloat, totalWidth: CGFloat) -> Int {
        let gestureProgress = translation / (totalWidth * pageSwitchThreshold * 2.0)
        let indexDiff = Int(gestureProgress.rounded())
        return selectedIndex - indexDiff
    }
}

// MARK: - Convenience extensions

extension CardsInfoPagerView where Data.Element: Identifiable, Data.Element.ID == ID {
    init(
        data: Data,
        selectedIndex: Binding<Int>,
        @ViewBuilder headerFactory: @escaping HeaderFactory,
        @ViewBuilder contentFactory: @escaping ContentFactory
    ) {
        self.init(
            data: data,
            id: \.id,
            selectedIndex: selectedIndex,
            headerFactory: headerFactory,
            contentFactory: contentFactory
        )
    }
}

// MARK: - Auxiliary types

private struct BodyAnimationModifier: Animatable, ViewModifier {
    var progress: CGFloat
    let verticalOffset: CGFloat
    let hasNextIndexToSelect: Bool

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let ratio = !hasNextIndexToSelect && progress > 0.5
            ? 1.0
            : sin(.pi * progress)

        return content
            .opacity(1.0 - Double(ratio))
            .offset(y: verticalOffset * ratio)
    }
}

// MARK: - Setupable protocol conformance

extension CardsInfoPagerView: Setupable {
    func pageSwitchAnimation(_ animation: Animation) -> Self {
        map { $0.pageSwitchAnimation = animation }
    }

    func pageSwitchThreshold(_ threshold: CGFloat) -> Self {
        map { $0.pageSwitchThreshold = threshold }
    }

    func contentViewVerticalOffset(_ offset: CGFloat) -> Self {
        map { $0.contentViewVerticalOffset = offset }
    }
}

// MARK: - Previews

struct CardsInfoPagerView_Previews: PreviewProvider {
    private struct CardsInfoPagerPreview: View {
        @ObservedObject var headerPreviewProvider: FakeCardHeaderPreviewProvider = .init()

        @ObservedObject var pagePreviewProvider: CardsInfoPagerPreviewProvider = .init()

        @State private var selectedIndex = 0

        var body: some View {
            ZStack {
                Colors.Background.secondary
                    .ignoresSafeArea()

                CardsInfoPagerView(
                    data: zip(headerPreviewProvider.models.indices, pagePreviewProvider.models.indices).map(\.0),
                    selectedIndex: $selectedIndex,
                    headerFactory: { index in
                        MultiWalletCardHeaderView(viewModel: headerPreviewProvider.models[index])
                            .padding(.horizontal)
                            .cornerRadius(14.0)
                    },
                    contentFactory: { index in
                        DummyCardInfoPageView(viewModel: pagePreviewProvider.models[index])
                    }
                )
                .pageSwitchThreshold(0.4)
                .contentViewVerticalOffset(64.0)
            }
        }
    }

    private struct DummyCardInfoPageView: View {
        @ObservedObject var viewModel: CardInfoPagePreviewViewModel

        var body: some View {
            List(viewModel.cellViewModels, id: \.id) { cellViewModel in
                DummyCardInfoPageCellView(viewModel: cellViewModel)
            }
        }
    }

    private struct DummyCardInfoPageCellView: View {
        @ObservedObject var viewModel: CardInfoPageCellPreviewViewModel

        var body: some View {
            VStack {
                Text(viewModel.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .allowsTightening(true)

                Button("Press me!") { viewModel.tapCount += 1 }
            }
            .infinityFrame()
        }
    }

    static var previews: some View {
        CardsInfoPagerPreview()
    }
}
