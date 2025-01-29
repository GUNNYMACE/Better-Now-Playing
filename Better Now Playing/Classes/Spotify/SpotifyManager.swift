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
    //weak var delegate: SpotifyManagerDelegate?
    @Published var currentAuthStatus = SpotifyAuthStatus.notAuthorized
    @Published var currentTrackTitle: String?
    @Published var currentTrackArtist: String?
    @Published var currentTrackAlbumName: String?
    @Published var currentTrackImage: UIImage?
    
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
    
    //MARK: Spotify Events
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("Established connection: app")
        appRemote.playerAPI?.delegate = self
        appRemote.playerAPI?.subscribe { result, error in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
                return
            }
            print("Subscribed to player state")
        }
    }
    func playerStateDidChange(_ playerState: any SPTAppRemotePlayerState) {
        print("Change in player state")
        currentTrackTitle = playerState.track.name
        currentTrackArtist = playerState.track.artist.name
        currentTrackAlbumName = playerState.track.album.name
        getArtwork(for: playerState.track)
        //delegate?.sendChange()
    }

    func getArtwork(for track: SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.currentTrackImage = image
            }
        })
    }
    
    //MARK: Unused Methods (Required)
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("session initiated")
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: any Error) {
        print("session failed")
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: (any Error)?) {
        print("Failed Connection: app")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: (any Error)?) {
        print("Disconected: app")
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
    case authorized
    case notAuthorized
    case unknown
}

//protocol SpotifyManagerDelegate: AnyObject {
//    func sendChange()
//}
//
//class SpotifyManagerDelegateWrapper: SpotifyManagerDelegate {
//    var sendChangeHandler: (() -> Void)?
//
//    func sendChange() {
//        sendChangeHandler?()
//    }
//}
