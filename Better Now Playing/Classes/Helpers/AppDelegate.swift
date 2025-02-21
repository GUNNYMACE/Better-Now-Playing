//
//  AppDelegate.swift
//  Better Now Playing
//
//  Created by Mason Likens on 1/31/25.
//  Handles the app closure.
import UIKit

//FIXME: BRO make AppDelegate work for Spotify Manager


class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        // This method is called when the app is about to terminate.
        print("App is closed")
        if (SpotifyManager.shared.appRemote.isConnected) {
            SpotifyManager.shared.appRemote.disconnect()
        }
        //FIXME: Make a notif to connect to iPhoneContentView
    }
}
