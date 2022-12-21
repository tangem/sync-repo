//
//  MeetTangemStoryPage.swift
//  Tangem
//
//  Created by Andrey Chukavin on 14.02.2022.
//  Copyright © 2022 Tangem AG. All rights reserved.
//

import SwiftUI

struct MeetTangemStoryPage: View {
    @Binding var progress: Double
    var immediatelyShowButtons: Bool
    let isScanning: Bool
    let scanCard: (() -> Void)
    let orderCard: (() -> Void)

    private let words: [LocalizedStringKey] = [
        "",
        "",
        L10n.storyMeetBuy,
        L10n.storyMeetStore,
        L10n.storyMeetSend,
        L10n.storyMeetPay,
        L10n.storyMeetExchange,
        L10n.storyMeetBorrow,
        L10n.storyMeetLend,
        L10n.storyMeetLend,
        // Duplicate the last word to make it last longer
//        L10n.storyMeetStake, // no stake for now
        "",
    ]

    private let wordListProgressEnd = 0.6

    private let titleProgressStart = 0.7
    private let titleProgressEnd = 0.9

    var body: some View {
        ZStack {
            ForEach(0 ..< words.count) { index in
                Text(words[index])
                    .foregroundColor(.white)
                    .font(.system(size: 60, weight: .semibold))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .padding(.horizontal)
                    .modifier(AnimatableVisibilityModifier(
                        progress: progress,
                        start: Double(index) / Double(words.count) * wordListProgressEnd,
                        end: Double(index + 1) / Double(words.count) * wordListProgressEnd
                    ))
            }

            VStack(spacing: 0) {
                StoriesTangemLogo()
                    .padding()
                    .modifier(AnimatableVisibilityModifier(
                        progress: progress,
                        start: wordListProgressEnd,
                        end: .infinity
                    ))

                Text(L10n.storyMeetTitle)
                    .font(.system(size: 60, weight: .semibold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.bottom, 10)
                    .modifier(AnimatableOffsetModifier(
                        progress: progress,
                        start: titleProgressStart,
                        end: titleProgressEnd,
                        curveX: { _ in
                            0
                        }, curveY: {
                            40 * pow(2, -15 * $0)
                        }
                    ))
                    .modifier(AnimatableVisibilityModifier(
                        progress: progress,
                        start: titleProgressStart,
                        end: .infinity
                    ))

                Color.clear
                    .background(
                        Image("hand_with_card")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fixedSize(horizontal: false, vertical: true)
                            .edgesIgnoringSafeArea(.bottom)
                            .overlay(
                                LinearGradient(stops: [
                                    Gradient.Stop(color: Color("tangem_story_background").opacity(0), location: 0.7),
                                    Gradient.Stop(color: Color("tangem_story_background"), location: 1),
                                ], startPoint: .top, endPoint: .bottom)
                                    .frame(minWidth: 1000)
                            )
                            .storyImageAppearanceModifier(
                                progress: progress,
                                start: wordListProgressEnd,
                                fastMovementStartCoefficient: 1.1,
                                fastMovementSpeedCoefficient: -25,
                                fastMovementEnd: 0.25,
                                slowMovementSpeedCoefficient: 0.1
                            )
                            .modifier(AnimatableVisibilityModifier(
                                progress: progress,
                                start: wordListProgressEnd,
                                end: 1
                            ))
                        ,
                        alignment: .top
                    )
            }

            VStack {
                Spacer()

                StoriesBottomButtons(scanColorStyle: .primary, orderColorStyle: .secondary, isScanning: isScanning, scanCard: scanCard, orderCard: orderCard)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .modifier(AnimatableVisibilityModifier(
                progress: progress,
                start: immediatelyShowButtons ? 0 : wordListProgressEnd,
                end: .infinity
            ))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("tangem_story_background").edgesIgnoringSafeArea(.all))
    }
}


struct MeetTangemStoryPage_Previews: PreviewProvider {
    static var previews: some View {
        MeetTangemStoryPage(progress: .constant(0.8), immediatelyShowButtons: false, isScanning: false) { } orderCard: { }
            .previewGroup(devices: [.iPhone7, .iPhone12ProMax], withZoomed: false)
            .environment(\.colorScheme, .dark)
    }
}
