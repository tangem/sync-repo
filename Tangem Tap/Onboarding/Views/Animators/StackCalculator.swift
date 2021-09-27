//
//  StackCalculator.swift
//  Tangem Tap
//
//  Created by Andrew Son on 09.09.2021.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import SwiftUI

// TODO: Add updating number of cards in stack
struct StackCalculator {
    
    private(set) var prehideAnimSettings: CardAnimSettings = .zero
    // TODO: Refactor to: hide cards settings and add function that returns settings for specified index if it in array bounds, otherwise return zero settings
    private(set) var cardsSettings: [CardAnimSettings] = []
    
    private let maxZIndex: Double = 100
    
    private var containerSize: CGSize = .zero
    private var settings: CardsStackAnimatorSettings = .zero
    
    mutating func setup(for container: CGSize, with settings: CardsStackAnimatorSettings) {
        containerSize = container
        self.settings = settings
        populateSettings()
    }
    
    mutating private func populateSettings() {
        prehideAnimSettings = .zero
        cardsSettings = []
        for i in 0..<settings.numberOfCards {
            cardsSettings.append(cardInStackSettings(at: i))
        }
        prehideAnimSettings = calculatePrehideSettings(for: 0)
    }
    
    private func calculatePrehideSettings(for index: Int) -> CardAnimSettings {
        guard cardsSettings.count > 0 else { return .zero }
        
        let settings = cardsSettings[0]
        let targetFrameHeight = settings.frame.height
        
        return .init(frame: settings.frame,
                     offset: CGSize(width: self.settings.topCardOffset.width, height: self.settings.topCardOffset.height - (settings.frame.height / 2 + targetFrameHeight / 2) - 10),
                     scale: 1.0,
                     opacity: 1.0,
                     zIndex: maxZIndex + 100,
                     rotationAngle: Angle(degrees: 0),
                     animType: .linear,
                     animDuration: 0.15)
    }
    
    private func cardInStackSettings(at index: Int) -> CardAnimSettings {
        let floatIndex = CGFloat(index)
        let doubleIndex = Double(index)
        let offset: CGFloat = settings.cardsVerticalOffset * 2 * floatIndex + settings.topCardOffset.height
        let scale: CGFloat = max(1 - settings.scaleStep * floatIndex, 0)
        let opacity: Double = max(1 - settings.opacityStep * doubleIndex, 0)
        let zIndex: Double = maxZIndex - Double(index)
        
        return .init(frame: settings.topCardSize,
                     offset: .init(width: settings.topCardOffset.width, height: offset),
                     scale: scale,
                     opacity: opacity,
                     zIndex: zIndex,
                     rotationAngle: .zero,
                     animType: .linear,
                     animDuration: 0.3)
    }
    
}
