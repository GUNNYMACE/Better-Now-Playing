//
//  AppDelegate.swift
//  Better Now Playing
//
//  Created by Mason Likens on 1/4/25.
//
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("ran1")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        print("ran2")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        print("ran3")
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Trigger")
        // Handle the callback from Spotify authentication
            if let sourceApp = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, sourceApp == "com.spotify.client" {
                // Process the URL to extract the access token
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                    for queryItem in components.queryItems ?? [] {
                        if queryItem.name == "access_token" {
                            if let accessToken = queryItem.value {
                                print("Spotify Access Token: \(accessToken)")
                                // Handle the access token (e.g., save it, use it for API calls, etc.)
                            }
                        }
                    }
                }
                return true
            }
            return false
        }
}
