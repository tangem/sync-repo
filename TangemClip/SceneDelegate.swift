//
//  SceneDelegate.swift
//  TangemClip
//
//  Created by Andrew Son on 05/03/21.
//  Copyright © 2021 Tangem AG. All rights reserved.
//

import UIKit
import SwiftUI

class ClipsLogger: TangemSdkLogger {
    private let fileManager = FileManager.default
    
    var scanLogFileData: Data? {
        try? Data(contentsOf: scanLogsFileUrl)
    }
    
    var logs: String {
        let emptyLogs = "Failed to retreive logs"
        guard
            let data = scanLogFileData,
            let lgs = String(data: data, encoding: .utf8)
        else {
            return emptyLogs
        }
        
        return lgs
    }
    
    private var scanLogsFileUrl: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("scanLogs.txt")
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss:SSS"
        return formatter
    }()
    
    private var isRecordingLogs: Bool = false
    
    init() {
        try? fileManager.removeItem(at: scanLogsFileUrl)
    }
    
    func log(_ message: String, level: Log.Level) {
        let formattedMessage = "\(self.dateFormatter.string(from: Date())): \(message)\n"
        let messageData = formattedMessage.data(using: .utf8)!
        if let handler = try? FileHandle(forWritingTo: scanLogsFileUrl) {
            handler.seekToEndOfFile()
            handler.write(messageData)
            handler.closeFile()
        } else {
            try? messageData.write(to: scanLogsFileUrl)
        }
    }
}

let clipsLogger = ClipsLogger()

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let assembly = Assembly()
    
    var userPrefs: UserPrefsService {
        assembly.services.userPrefsService
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let contentView = MainView(viewModel: assembly.getMainViewModel())

        clipsLogger.log("Scene will connect to session with activity: \(connectionOptions.userActivities.first), SceneDelegate activity: \(userActivity). Type: \(connectionOptions.userActivities.first?.activityType). Webpage url: \(connectionOptions.userActivities.first?.webpageURL)", level: .debug)
        handle(connectionOptions.userActivities.first, in: scene)
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        clipsLogger.log("Scene continue with activity: \(userActivity), SceneDelegate activity: \(userActivity). Type: \(userActivity.activityType). Webpage url: \(userActivity.webpageURL)", level: .debug)
        handle(userActivity, in: scene)
    }
    
    private func handle(_ activity: NSUserActivity?, in scene: UIScene) {
        // Get URL components from the incoming user activity
        let url: URL
        clipsLogger.log("Handling activity: \(activity). Type: \(activity?.activityType). Webpage url: \(activity?.webpageURL)", level: .debug)
        if let activity = activity, activity.activityType == NSUserActivityTypeBrowsingWeb, let incomingURL = activity.webpageURL {
            if incomingURL.absoluteString == "https://example.com" {
                clipsLogger.log("Scene found url but this is example.com. Returning without action", level: .debug)
                return
            }
            url = incomingURL
            scene.userActivity = activity
        } else if let savedNdef = URL(string: userPrefs.lastScannedNdef) {
            clipsLogger.log("Scene not found url. Reverting to saved url: \(savedNdef)", level: .debug)
            url = savedNdef
        } else {
            clipsLogger.log("Scene not found url and not found saved url. Replacing with preset link", level: .debug)
            url = URL(string: "https://tangem.com/ndef/CB79")!
        }
        
        let link = url.absoluteString
        let batch = url.lastPathComponent
        assembly.updateAppClipCard(with: batch, fullLink: link)
        userPrefs.lastScannedNdef = link
        if !userPrefs.scannedNdefs.contains(link) {
            userPrefs.scannedNdefs.append(link)
        }
    }

}

