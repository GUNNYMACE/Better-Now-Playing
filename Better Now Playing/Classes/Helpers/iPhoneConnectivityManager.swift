//
//  WatchConnectivityManager.swift
//  Better Now Playing
//
//  Created by Mason Likens on 4/15/25.
//

import Foundation
import WatchConnectivity
import UIKit

class iPhoneConnectivityManager: NSObject, WCSessionDelegate {
    static let shared = iPhoneConnectivityManager()
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendNowPlayingData(title: String, artist: String, albumTitle: String, albumArt: UIImage, currentPlayer: CurrentMusicPlayer, currentStatus: currentState) {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            print("Watch is not paired or app is not installed")
            return
        }
        
        // Resize the image
        let targetSize = CGSize(width: 25, height: 25) // Adjust size as needed
        guard let resizedAlbumArt = albumArt.resized(to: targetSize),
              let albumArtData = resizedAlbumArt.pngData() else {
            print("Failed to resize or convert UIImage to Data")
            return
        }
        
        // Prepare the context
        let context: [String: Any] = [
            "title": title,
            "artist": artist,
            "albumTitle": albumTitle,
            "albumArt": albumArtData,
            "currentPlayer": currentPlayer.rawValue,
            "currentStatus": currentStatus.rawValue
        ]
        
        print("Sending now playing data...")
        
        do {
            try WCSession.default.updateApplicationContext(context)
        } catch {
            print("Failed to update application context: \(error.localizedDescription)")
        }
    }
    
    func sendUserInfo(title: String, artist: String, albumTitle: String, albumArt: UIImage, currentPlayer: CurrentMusicPlayer, currentStatus: currentState) {
        guard WCSession.default.isPaired && WCSession.default.isWatchAppInstalled else {
            print("Watch is not paired or app is not installed")
            return
        }
        
        // Resize the image
        let targetSize = CGSize(width: 25, height: 25) // Adjust size as needed
        guard let resizedAlbumArt = albumArt.resized(to: targetSize),
              let albumArtData = resizedAlbumArt.pngData() else {
            print("Failed to resize or convert UIImage to Data")
            return
        }
        
        // Prepare the user info dictionary
        let userInfo: [String: Any] = [
            "title": title,
            "artist": artist,
            "albumTitle": albumTitle,
            "albumArt": albumArtData,
            "currentPlayer": currentPlayer.rawValue,
            "currentStatus": currentStatus.rawValue
        ]
        
        // Send the user info
        WCSession.default.transferUserInfo(userInfo)
        print("User info sent: \(userInfo)")
    }
    
    // WCSessionDelegate methods (required)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated successfully")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    
    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        DispatchQueue.main.async {
            if let request = message["request"] as? String {
                switch request {
                case "updateNowPlaying":
                    NotificationCenter.default.post(name: .remoteSendDataCommand, object: nil, userInfo: message)
                    print("Received request to send data")
                case "changePlayer":
                    NotificationCenter.default.post(name: .remoteChangePlayerCommand, object: nil, userInfo: message)
                    print("Received request to change player")
                default:
                    print("Unknown request received: \(request)")
                }
            }
        }
    }

    // Method to change the music player
    private func changeMusicPlayer(to newPlayer: CurrentMusicPlayer) {
        // Implement logic to switch the music player
        print("Changing music player to: \(newPlayer)")
        // Example: Update a property or notify other parts of the app
    }
}

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
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
    static let remoteSendDataCommand = Notification.Name("remoteSendDataCommand")
    static let remoteChangePlayerCommand = Notification.Name("remoteChangePlayerCommand")
}
