//
//  SpotifyManager.swift
//  Better Now Playing
//
//  Created by Mason Likens on 1/2/25.
//

import UIKit
import WebKit

class SpotifyManager: UIViewController, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
    //MARK: - Vars Public and Private
    public static var shared = SpotifyManager()
    public var firstAppError = false

    //Status Vars
    @Published var currentStatus = SpotifyAuthStatus.offline {
        didSet {
            //Sends if Change in status occors
            NotificationCenter.default.post(name: .spotifyChangeOccurred, object: nil)
        }
    }
    @Published var currentTrackTitle: String?
    @Published var currentTrackArtist: String?
    @Published var currentTrackAlbumName: String?
    @Published var currentTrackImage: UIImage? {
        didSet {
            //Sends that new info is ready to update (Only updates if image is ready)
            NotificationCenter.default.post(name: .spotifyTrackUpdated, object: nil)
        }
    }
    @Published var errorDetails: String?
    
    //Debug Descpition
    public override var description: String {
        return "\(SpotifyManager.shared.currentStatus):\(SpotifyManager.shared.currentTrackTitle ?? "nil"):\(SpotifyManager.shared.currentTrackArtist ?? "nil"):\(SpotifyManager.shared.currentTrackAlbumName ?? "nil")"
    }
    
    
    
    
    
    // MARK: - Spotify Authorization / Vars
     var responseCode: String? {
         didSet {
             fetchAccessToken { (dictionary, error) in
                 if let error = error {
                     print("Fetching token request error \(error)")
                     return
                 }
                 let accessToken = dictionary!["access_token"] as! String
                 print("Access Token: \(accessToken)")
                 DispatchQueue.main.async {
                     self.appRemote.connectionParameters.accessToken = accessToken
                     self.appRemote.connect()
                 }
             }
         }
     }
    
    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()
    
    var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
        configuration.playURI = ""
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    
    
    
    
    
    //MARK: Lifecycle
    func attemptAuth() {
        guard let sessionManager = sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .clientOnly, campaign: "")
    }
    func URLRecived(_ URL: URL) {
        guard let components = URLComponents(url: URL, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else {
            return
        }
        print("URL Recived")
        for queryItem in queryItems {
            if queryItem.name == "code", let code = queryItem.value {
                responseCode = code
                appRemote.connectionParameters.accessToken = code
                self.appRemote.connect()
            }
        }
    }
    func doDisconnect() {
        // Disconnect the app remote
        if appRemote.isConnected {
            appRemote.disconnect()
        }
        
        // Reset all published properties to their default values
        currentStatus = .offline
        currentTrackTitle = nil
        currentTrackArtist = nil
        currentTrackAlbumName = nil
        currentTrackImage = nil
        firstAppError = false
        errorDetails = nil
        
        // Clear the access token
        if let token = accessToken, !token.isEmpty {
            print("Retaining access token for reconnection.")
        } else {
            print("Access token is invalid, refreshing...")
            fetchAccessToken { [weak self] (dictionary, error) in
                if let error = error {
                    print("Error refreshing token: \(error.localizedDescription)")
                    return
                }
                if let newToken = dictionary?["access_token"] as? String {
                    self?.accessToken = newToken
                }
            }
        }
    }
    
    
    
    
    
    //MARK: Spotify Events
    //AppRemote Connection
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Established connection: app")
        appRemote.playerAPI?.delegate = self
        currentStatus = .online
        appRemote.playerAPI?.subscribe { result, error in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
                return
            }
            print("Subscribed to player state")
        }
    }

    //AppRemote Error
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        if !firstAppError {
            // Ignore the token-related error
            firstAppError = true
            print("Ignoring First Error")
        } else {
            print("Failed Connection: app")
            print("Error: \(String(describing: error?.localizedDescription))")
            errorDetails = "App Remote Error"
            NotificationCenter.default.post(name: .spotifyChangeOccurred, object: error)
        }
    }
    
    //AppRemote Disconnect
    //FIXME: Does this happen with or without error or both?????
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        print("Spotify: Disconnection")
        currentStatus = .offline
        NotificationCenter.default.post(name: .spotifyChangeOccurred, object: error)
    }
    
    
    
    //Session Manager Connect
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        //print("session initiated")
    }
    
    //Session Manager Error
    func sessionManager(manager: SPTSessionManager, didFailWith error: any Error) {
        print("Spotify: Session Failed")
        errorDetails = "Session Manager Error"
        currentStatus = .error
        NotificationCenter.default.post(name: .spotifyChangeOccurred, object: error)
    }
    
    
    
    //Update to Player
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        print("Change in player state")
        currentTrackTitle = playerState.track.name
        currentTrackArtist = playerState.track.artist.name
        currentTrackAlbumName = playerState.track.album.name
        getArtwork(for: playerState.track)
        //delegate?.sendChange()
    }
    
    //Fetches Current Artwork
    func getArtwork(for track: SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.currentTrackImage = image
            }
        })
    }
    
    
    
    
    
    //MARK: Networking
    func fetchAccessToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        print("fetching token")
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let spotifyAuthKey = "Basic \((spotifyClientId + ":" + spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey,
                                       "Content-Type": "application/x-www-form-urlencoded"]

        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ")

        requestBodyComponents.queryItems = [
            URLQueryItem(name: "client_id", value: spotifyClientId),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: responseCode!),
            URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString),
            URLQueryItem(name: "code_verifier", value: ""), // not currently used
            URLQueryItem(name: "scope", value: scopeAsString),
        ]

        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,                              // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                (200 ..< 300) ~= response.statusCode,         // is statusCode 2XX
                error == nil else {                           // was there no error, otherwise ...
                    print("Error fetching token \(error?.localizedDescription ?? "")")
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .spotifyChangeOccurred, object: error)
                        }
                    return completion(nil, error)
                }
            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("Access Token Dictionary=", responseObject ?? "")
            completion(responseObject, nil)
        }
        task.resume()
    }
}

enum SpotifyAuthStatus {
    case online
    case offline
    case error
    case unknown
}

extension Notification.Name {
    static let spotifyTrackUpdated = Notification.Name("spotifyTrackUpdated")
    static let spotifyChangeOccurred = Notification.Name("spotifyChangeOccurred")
}
