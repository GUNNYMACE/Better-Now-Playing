//
//  Better_Now_PlayingApp.swift
//  Better Now Playing Watch App
//
//  Created by Mason Likens on 10/2/24.
//

import SwiftUI
import WatchKit
import ClockKit

@main
struct Better_Now_Playing_Watch_AppApp: App {
//    @WKExtensionDelegateAdaptor private var extensionDelegate: ExtensionDelegate
    @WKApplicationDelegateAdaptor private var extensionDelegate: ExtensionDelegate

    var body: some Scene {
        WindowGroup {
            WatchContentView()
        }
    }
}

class ExtensionDelegate: NSObject, WKApplicationDelegate {
    func handleUserActivity(_ userInfo: [AnyHashable : Any]?) {
        print("Running")
        if let date = userInfo?[CLKLaunchedTimelineEntryDateKey] as? Date {
            // Handoff from complication
            print("Comp")
        }
        else {
            // Handoff from elsewhere
            print("Non-Comp")
        }
    }
}
