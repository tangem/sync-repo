//
//  SceneDelegate.swift
//  Tangem Tap
//
//  Created by Alexander Osokin on 15.07.2020.
//  Copyright © 2020 Tangem AG. All rights reserved.
//

import UIKit
import SwiftUI
import TangemSdk
import BlockchainSdk

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let assembly = Assembly()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        assembly.services.walletConnectService.restore()
        // Create the SwiftUI view that provides the window contents.
        assembly.services.userPrefsService.numberOfLaunches += 1
        print("Launch number:", assembly.services.userPrefsService.numberOfLaunches)
     
        let vm = assembly.makeReadViewModel()
        let contentView = ContentView() { ReadView(viewModel: vm) }
        .environmentObject(assembly)
        .environmentObject(assembly.services.navigationCoordinator)
            
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
        handleActivity(connectionOptions.userActivities)
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleActivity([userActivity])
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleURL(contexts: URLContexts)
    }
    
    private func handleActivity(_ userActivity: Set<NSUserActivity>) {
        userActivity.forEach {
            switch $0.activityType {
            case NSUserActivityTypeBrowsingWeb:
                guard let url = $0.webpageURL else { return }
                
                handleUrl(url)
            case String(describing: ScanTangemCardIntent.self):
                if window?.rootViewController?.presentedViewController != nil {
                    window?.rootViewController?.dismiss(animated: false, completion: nil)
                }
                assembly.services.navigationCoordinator.readToMain = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.assembly.makeReadViewModel().scan()
                }
                
            default: return
            }
        }
    }
    
    private func handleURL(contexts: Set<UIOpenURLContext>) {
        if let url = contexts.first?.url {
            handleUrl(url)
        }
    }
    
    private func handleUrl(_ url: URL) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.assembly.services.urlHandlers.forEach {
                $0.handle(url: url)
            }
        }
    }
}

