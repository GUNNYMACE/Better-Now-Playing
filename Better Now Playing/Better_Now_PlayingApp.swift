//
//  Better_Now_PlayingApp.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/2/24.
//

import SwiftUI
import WatchConnectivity

@main
struct Better_Now_PlayingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            iPhoneContentView()
        }
        //FIXME: Move to iPhoneContentView when needed
        .onChange(of: scenePhase, initial: true) { oldPhase, newPhase in
            switch newPhase {
                case .background:
                    print("App is in the background")
                    // Handle background state
                case .inactive:
                    print("App is leaving Foreground")
                    // Handle inactive state
                case .active:
                    print("App is in Foreground")
                    // Handle active state
                @unknown default:
                    print("Unknown scene phase")
            }
        }
    }
}
