//
//  StoriesViewModel.swift
//  StoriesDemo
//
//  Created by Andrey Chukavin on 26.01.2022.
//

import Foundation
import Combine
import SwiftUI

class StoriesViewModel: ViewModel, ObservableObject {
    var assembly: Assembly!
    var navigation: NavigationCoordinator!
    
    @Published var currentPage: WelcomeStoryPage = WelcomeStoryPage.allCases.first!
    @Published var currentProgress = 0.0
    let pages = WelcomeStoryPage.allCases
    
    private var timerSubscription: AnyCancellable?
    private var longTapTimerSubscription: AnyCancellable?
    private var longTapDetected = false
    private var currentDragLocation: CGPoint?
    private var bag: Set<AnyCancellable> = []
    
    private let longTapDuration = 0.25
    private let minimumSwipeDistance = 100.0
    
    init() {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.pauseTimer()
            }
            .store(in: &bag)
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.resumeTimer()
            }
            .store(in: &bag)
    }
    
    func onAppear() {
        restartTimer()
    }
    
    func onDisappear() {
        pauseTimer()
    }
    
    func didDrag(_ current: CGPoint) {
        if longTapDetected {
            return
        }
        
        if let currentDragLocation = currentDragLocation, currentDragLocation.distance(to: current) < minimumSwipeDistance {
            return
        }

        currentDragLocation = current
        pauseTimer()
        
        longTapTimerSubscription = Timer.publish(every: longTapDuration, on: RunLoop.main, in: .default)
            .autoconnect()
            .sink { [unowned self] _ in
                self.currentDragLocation = nil
                self.longTapTimerSubscription = nil
                self.longTapDetected = true
            }
    }
    
    func didEndDrag(_ current: CGPoint, destination: CGPoint, viewWidth: CGFloat) {
        if let currentDragLocation = currentDragLocation {
            let distance = (destination.x - current.x)
            
            let moveForward: Bool
            if abs(distance) < minimumSwipeDistance {
                moveForward = currentDragLocation.x > viewWidth / 2
            } else {
                moveForward = distance > 0
            }

            move(forward: moveForward)
        } else {
            resumeTimer()
        }
        
        currentDragLocation = nil
        longTapTimerSubscription = nil
        longTapDetected = false
    }
    
    private func move(forward: Bool) {
        currentPage = WelcomeStoryPage(rawValue: currentPage.rawValue + (forward ? 1 : -1)) ?? pages.first!
        restartTimer()
    }
    
    private func restartTimer() {
        currentProgress = 0
        resumeTimer()
    }
    
    private func pauseTimer() {
        timerSubscription = nil
    }
    
    private func resumeTimer() {
        let fps = currentPage.fps
        let storyDuration = currentPage.duration
        timerSubscription = Timer.publish(every: 1 / fps, on: .main, in: .default)
            .autoconnect()
            .sink { [unowned self] _ in
                if self.currentProgress >= 1 {
                    self.move(forward: true)
                } else {
                    self.currentProgress += 1 / fps / storyDuration
                }
            }
    }
}


fileprivate extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt(pow(self.x - other.x, 2) + pow(self.y - other.y, 2))
    }
}
