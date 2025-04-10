//
//  WatchConnectivityManager.swift
//  Better Now Playing Watch App
//
//  Created by Mason Likens on 4/15/25.
//

import Foundation
import WatchConnectivity
import UIKit
import WatchKit

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var nowPlayingData: (title: String, artist: String, albumTitle: String, albumArt: UIImage?) = ("", "", "", nil)
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // WCSessionDelegate method to receive application context
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            let title = applicationContext["title"] as? String ?? "Unknown Title"
            let artist = applicationContext["artist"] as? String ?? "Unknown Artist"
            let albumTitle = applicationContext["albumTitle"] as? String ?? "Unknown Album"
            
            var albumArt: UIImage? = nil
            if let albumArtData = applicationContext["albumArt"] as? Data {
                albumArt = UIImage(data: albumArtData)
            }
            
            let currentPlayerRawValue = applicationContext["currentPlayer"] as? String ?? CurrentMusicPlayer.none.rawValue
            let currentStatusRawValue = applicationContext["currentStatus"] as? String ?? currentState.unknown.rawValue
            
            let currentPlayer = CurrentMusicPlayer(rawValue: currentPlayerRawValue) ?? .none
            let currentStatus = currentState(rawValue: currentStatusRawValue) ?? .unknown
            
            // Update the published property
            self.nowPlayingData = (title, artist, albumTitle, albumArt)
            
            // Post a notification with the additional fields
            NotificationCenter.default.post(name: .nowPlayingDataUpdated, object: nil, userInfo: [
                "title": title,
                "artist": artist,
                "albumTitle": albumTitle,
                "albumArt": albumArt as Any,
                "currentPlayer": currentPlayer,
                "currentStatus": currentStatus
            ])
            
            // Log the received data for debugging
            print("Received in background: \(title), \(artist), \(albumTitle), Player: \(currentPlayer), Status: \(currentStatus)")
        }
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        DispatchQueue.main.async {
            let title = userInfo["title"] as? String ?? "Unknown Title"
            let artist = userInfo["artist"] as? String ?? "Unknown Artist"
            let albumTitle = userInfo["albumTitle"] as? String ?? "Unknown Album"
            
            var albumArt: UIImage? = nil
            if let albumArtData = userInfo["albumArt"] as? Data {
                albumArt = UIImage(data: albumArtData)
            }
            
            let currentPlayerRawValue = userInfo["currentPlayer"] as? String ?? CurrentMusicPlayer.none.rawValue
            let currentStatusRawValue = userInfo["currentStatus"] as? String ?? currentState.unknown.rawValue
            
            let currentPlayer = CurrentMusicPlayer(rawValue: currentPlayerRawValue) ?? .none
            let currentStatus = currentState(rawValue: currentStatusRawValue) ?? .unknown
            
            // Update the published property
            self.nowPlayingData = (title, artist, albumTitle, albumArt)
            
            // Post a notification with the additional fields
            NotificationCenter.default.post(name: .nowPlayingDataUpdated, object: nil, userInfo: [
                "title": title,
                "artist": artist,
                "albumTitle": albumTitle,
                "albumArt": albumArt as Any,
                "currentPlayer": currentPlayer,
                "currentStatus": currentStatus
            ])
            
            // Log the received data for debugging
            print("User info received: \(title), \(artist), \(albumTitle), Player: \(currentPlayer), Status: \(currentStatus)")
        }
    }
    
    // Handle background refresh tasks
    func handleBackgroundRefresh(task: WKApplicationRefreshBackgroundTask) {
        // Perform any necessary updates
        print("Handling background refresh task")
        
        // Simulate fetching data from the iPhone
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["request": "updateNowPlaying"], replyHandler: { response in
                if let title = response["title"] as? String,
                   let artist = response["artist"] as? String,
                   let albumTitle = response["albumTitle"] as? String,
                   let albumArtData = response["albumArt"] as? Data,
                   let albumArt = UIImage(data: albumArtData) {
                    DispatchQueue.main.async {
                        self.nowPlayingData = (title, artist, albumTitle, albumArt)
                    }
                }
            }, errorHandler: { error in
                print("Error fetching data: \(error.localizedDescription)")
            })
        }
        
        // Complete the task
        task.setTaskCompletedWithSnapshot(false)
    }
    
    func requestDataOrChangePlayer(newPlayer: CurrentMusicPlayer?) {
        guard WCSession.default.isReachable else {
            print("iPhone is not reachable")
            return
        }
        
        var message: [String: Any] = ["request": "updateNowPlaying"]
        
        // If a new player is specified, include it in the message
        if let newPlayer = newPlayer {
            message["newPlayer"] = newPlayer.rawValue
        }
        
        WCSession.default.sendMessage(message, replyHandler: { response in
            // Handle the response from the iPhone
            if let title = response["title"] as? String,
               let artist = response["artist"] as? String,
               let albumTitle = response["albumTitle"] as? String,
               let albumArtData = response["albumArt"] as? Data,
               let albumArt = UIImage(data: albumArtData) {
                DispatchQueue.main.async {
                    self.nowPlayingData = (title, artist, albumTitle, albumArt)
                }
            }
        }, errorHandler: { error in
            print("Error sending message: \(error.localizedDescription)")
        })
    }
    
    // WCSessionDelegate method to handle session activation
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully with state: \(activationState.rawValue)")
        }
    }

    // Handle when the session becomes inactive
//    func sessionDidBecomeInactive(_ session: WCSession) {
//        print("WCSession became inactive")
//    }
    
    // Handle when the session is deactivated
//    func sessionDidDeactivate(_ session: WCSession) {
//        print("WCSession deactivated")
//        WCSession.default.activate() // Reactivate the session
//    }
}

// Shared Enums
enum CurrentMusicPlayer: String {
    case none = "none"
    case appleMusic = "appleMusic"
    case spotify = "spotify"
}

enum currentState: String {
    case online = "online"
    case offline = "offline"
    case unknown = "unknown"
}

extension Notification.Name {
    static let nowPlayingDataUpdated = Notification.Name("nowPlayingDataUpdated")
}
