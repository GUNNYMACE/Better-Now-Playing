//
//  iPhoneContentView.swift
//  Better Now Playing
//
//  Remade by Mason Likens on 3/19/25.
//

import SwiftUI

struct iPhoneContentView: View {
    //MARK: Style Vars
    private let defaultPlayer: CurrentMusicPlayer = .spotify
    private let topBarHeight: CGFloat = 85
    private let musicDistanceFromTopBar: CGFloat = 50
    
    
    
    
    
    //MARK: Status Vars
    @State var currentPlayer: CurrentMusicPlayer = .spotify //{
        //didSet {checkTopBarStatus()}
    //}
    
    //TopBar
    @State private var barColor: Color = .red
    @State private var barText: String = "Spotify Not Connected"
    @State private var interactText: String = "Tap to Connect"
    
    //Current Music Data
    @State var currentSongName: String = "-"
    @State var currentSongArtist: String = "Player Not Connected"
    @State var currentSongAlbum: String = "-"
    @State var currentSongArtwork: UIImage = UIImage(named: "MusicBlank")!
    
    //Settings
    @State private var isSettingsOpen: Bool = false
    
    //Alerts
    @State private var showTopAlert = false
    @State private var doDisconnectPrompt: Bool = false
    @State private var showErrorActive = false
    @State private var showDebugAlert = false
    
    // Add a state variable to control the zoom animation
    @State private var backgroundScale: CGFloat = 1.0
    
    //MARK: Players & Watch Connectivity
    @StateObject var apPlayer: AppleMusicPlayer = AppleMusicPlayer()
    var spotifyPlayer: SpotifyManager = SpotifyManager()
    
    var manager = iPhoneConnectivityManager.shared
    
    // Computed property to determine dynamic colors based on album art brightness
    var dynamicColors: (text: Color, buttonBackground: Color, buttonIcon: Color) {
        if let brightness = currentSongArtwork.averageBrightness(), brightness > 0.7 {
            return (text: .black, buttonBackground: .black, buttonIcon: .white) // Bright images
        } else {
            return (text: .white, buttonBackground: .white, buttonIcon: .black) // Dark images
        }
    }
    
    
    
    
    
    //MARK: Main Body
    var body: some View {
        ZStack {
            //MARK: Image Background
            // Animated blurred background using the album art
            Image(uiImage: currentSongArtwork)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .blur(radius: 14)
                .clipped()
                .offset(y: 40) // Apply the animated offset
                .scaleEffect(backgroundScale) // Apply the animated scale effect
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // Start the zoom animation when the view appears
                    withAnimation(
                        Animation.easeInOut(duration: 5.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        backgroundScale = 1.1 // Slightly zoom in and out
                    }
                }

            VStack {
                //MARK: Top Bar
                ZStack {
                    Rectangle()
                        .fill(barColor)
                        .frame(height: topBarHeight+20)
                    VStack {
                        Text(barText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .font(.headline)
                        Text(interactText) // Add placeholder text here
                            .foregroundColor(.white)
                            .font(.subheadline)
                    }
                    .padding(.top, topBarHeight - 30)
                }
                .onTapGesture {
                    print(showTopAlert)
                    showTopAlert = true
                }
                .edgesIgnoringSafeArea(.top)

                Spacer()
                    .frame(height: musicDistanceFromTopBar)

                //MARK: Music Info
                VStack {
                    Image(uiImage: currentSongArtwork)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 350.0, height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    Group {
                        Text(currentSongName)
                        Text(currentSongArtist)
                        Text(currentSongAlbum)
                    }
                    .font(.title3)
                    .foregroundColor(dynamicColors.text)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                //MARK: Bottom Buttons
                HStack {
                    // Left Settings Button
                    Button(action: {
                        isSettingsOpen = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(dynamicColors.buttonIcon)
                            .padding()
                            .background(Circle().fill(dynamicColors.buttonBackground))
                    }
                    .padding(.leading, 40)
                    .padding(.bottom, 60)
                    .buttonStyle(.plain)

                    Spacer()

                    // Right CurrentPlayerMenu Button
                    Menu {
                        // Spotify
                        Button(action: {
                            defaultInfo()
                            currentPlayer = .spotify
                            checkTopBarStatus()
                            updateInfo()
                        }) {
                            Label("Spotify", systemImage: "music.note")
                        }

                        // Apple Music
                        Button(action: {
                            defaultInfo()
                            currentPlayer = .appleMusic
                            checkTopBarStatus()
                            updateInfo()
                            manager.sendUserInfo(title: currentSongName,
                                                 artist: currentSongArtist,
                                                 albumTitle: currentSongAlbum,
                                                 albumArt: currentSongArtwork,
                                                 currentPlayer: .appleMusic,
                                                 currentStatus: .unknown)
                        }) {
                            Label("Apple Music", systemImage: "music.note.list")
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(dynamicColors.buttonIcon)
                            .padding()
                            .background(Circle().fill(dynamicColors.buttonBackground))
                    }
                    .padding(.trailing, 40)
                    .padding(.bottom, 60)
                    .buttonStyle(.plain)
                }
            }
        } //End of ZStack
        
        
        
        
        
        //MARK: Settings Page
        .sheet(isPresented: $isSettingsOpen) {
            VStack {
                Text("Settings")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.top, 20.0)
                Form {
                    Section {
                        Button(action: {
                            print("Auth AP Music")
                            apPlayer.attemptAuth()
                            if (apPlayer.currentAuthStatus == .authorized) {
                                currentPlayer = .appleMusic
                            }
                        }) {
                            HStack(alignment: .center) {
                                Text("Authorize Apple Music")
                                if (apPlayer.currentAuthStatus == .authorized) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            
                        }
                        .disabled(apPlayer.currentAuthStatus != .notDetermined)
                    }
                    
                    Section {
                        Text("Version: 1.0")
                        Text("Debug Buttons")
                        Button("UserForceSend") {
                            manager.sendUserInfo(title: currentSongName, artist: currentSongArtist, albumTitle: currentSongAlbum, albumArt: currentSongArtwork, currentPlayer: currentPlayer, currentStatus: .online)
                        }
                    }
                }
                Spacer()
                
                Button("Close") {
                    isSettingsOpen = false
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
        }
        
        
        
        
        
        //MARK: URL & Notifications
        .onOpenURL { url in
            //Sends URL's to Spotify Class
            spotifyPlayer.URLRecived(url)
        }
        .onReceive(NotificationCenter.default.publisher(for: .spotifyTrackUpdated)) { _ in
            //Reciver for Spotify Update
            if (currentSongName == "-") {
                checkTopBarStatus()
                doDisconnectPrompt = true
            }
            updateInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: .spotifyChangeOccurred)) { notification in
            //Reciver for Spotify Errors
            showErrorActive = true
            defaultInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: .remoteSendDataCommand)) { notification in
            if spotifyPlayer.currentStatus != .online {
                spotifyPlayer.attemptAuth()
            }
            manager.sendUserInfo(title: currentSongName, artist: currentSongArtist, albumTitle: currentSongAlbum, albumArt: currentSongArtwork, currentPlayer: .spotify, currentStatus: .online)
        }
        .onReceive(NotificationCenter.default.publisher(for: .remoteChangePlayerCommand)) { notification in
            if let userInfo = notification.userInfo,
               let player = userInfo["player"] as? String {
                switch player {
                case "appleMusic":
                    currentPlayer = .appleMusic
                case "spotify":
                    currentPlayer = .spotify
                default:
                    print("Unknown player received: \(player)")
                }
            }
        }
        

        
        
         
        //MARK: Alerts
        
        //MARK: Top Bar Alerts
        .alert(isPresented: $showTopAlert) {
            //MARK: Spotify Alerts
            //Connection
            let type1 = Alert(
                title: Text("Launch Spotify"),
                message: Text("Launching the Spotify Controls requires a quick visit to the Spotify app."),
                primaryButton: .default(Text("Continue")) {
                    print("Launching Spotify")
                    spotifyPlayer.attemptAuth()
                    
                    // Check if Spotify is connected and update the UI
                    if spotifyPlayer.currentStatus == .online {
                        doDisconnectPrompt = true
                        updateInfo()
                        checkTopBarStatus()
                    } else {
                        showErrorActive = true
                        defaultInfo()
                    }
                },
                secondaryButton: .cancel {
                    print("Canceled Spotify Auth")
                }
            )
            
            //Disconnection
            let type2 = Alert(
                title: Text("Disconnect From Spotify"),
                message: Text("Are you sure you want to disconnect?"),
                primaryButton: .default(Text("Continue")) {
                    print("Disconnecting")
                    spotifyPlayer.doDisconnect()
                    
                    checkTopBarStatus()
                    defaultInfo()
                    doDisconnectPrompt = false
                },
                secondaryButton: .cancel {
                    print("Canceled Disconnection")
                }
            )
            
            //MARK Apple Music Alerts
            return spotifyPlayer.currentStatus == .online ? type2 : type1
        }
        
        //Error Alerts
        //Note: 2 Alerts create issues if on one Stack.
//        VStack() {}
//        .alert(isPresented: $showErrorActive) {
//            Alert(
//                title: Text("Error With Spotify"),
//                message: Text(spotifyPlayer.errorDetails ?? "Nil Error Details"),
//                primaryButton: .default(Text("Re-Launch Spotify")) {
//                    print("Error - Reattempting")
//                    spotifyPlayer.attemptAuth()
//                    updateInfo()
//                },
//                secondaryButton: .cancel {
//                    print("Canceled Spotify Auth, Keeping Current Player")
//                    // Do not reset the player, just update the info
//                    updateInfo()
//                }
//            )
//        }
    }
    
    
    
    
    
    //MARK: Functions
    //Updates the currently shown music.
    
    //MARK: Music Info Functions
    //Updates the current info 
    func updateInfo() {
        if currentPlayer == .appleMusic {
            currentSongName = apPlayer.currentSongName ?? "-"
            currentSongArtist = apPlayer.currentSongArtist ?? "No Song Currently Playing"
            currentSongAlbum = apPlayer.currentSongAlbum ?? "-"
            currentSongArtwork = apPlayer.currentSongArtwork ?? UIImage(named: "MusicBlank")!
        } else if currentPlayer == .spotify {
            if spotifyPlayer.currentStatus == .online {
                currentSongName = spotifyPlayer.currentTrackTitle ?? "-"
                currentSongArtist = spotifyPlayer.currentTrackArtist ?? "No Song Currently Playing"
                currentSongAlbum = spotifyPlayer.currentTrackAlbumName ?? "-"
                currentSongArtwork = spotifyPlayer.currentTrackImage ?? UIImage(named: "MusicBlank")!
                
//                manager.sendNowPlayingData(title: currentSongName, artist: currentSongArtist, albumTitle: currentSongAlbum, albumArt: currentSongArtwork)
                manager.sendUserInfo(title: currentSongName, artist: currentSongArtist, albumTitle: currentSongAlbum, albumArt: currentSongArtwork, currentPlayer: .spotify, currentStatus: .online)
            } else {
                print("Spotify is not connected")
                defaultInfo()
            }
        } else {
            print("None Selected")
        }
    }
    
    //Set info back to defaults without changing the current player.
    func defaultInfo() {
        currentSongName = "-"
        currentSongArtist = "Player Not Connected"
        currentSongAlbum = "-"
        currentSongArtwork = UIImage(named: "MusicBlank")!
    }
    
    
    
    
    
    //MARK: Top Bar Function
    func checkTopBarStatus() {
        //Spotify
        if currentPlayer == .spotify {
            if spotifyPlayer.currentStatus == .online {
                barColor = .green
                barText = "Spotify: Connected"
                interactText = "Tap to Disconnect"
            } else if spotifyPlayer.currentStatus == .offline {
                barColor = .red
                barText = "Spotify: Not Connected"
                interactText = "Tap to Connect"
            } else {
                barColor = .red
                barText = "Spotify: Error"
                interactText = "Restart the app"
            }
            
        //Apple Music
        } else if currentPlayer == .appleMusic {
            //FIXME: Apple Music
            barColor = .red
            //barText = "Apple Music"+barMessages[0]
            barText = "Apple Music: Currently Unavailable"
            interactText = "(No Auto Refresh)"
        }
    }
}





//MARK: Custom Types & Extras
//enum CurrentMusicPlayer {
//    case none
//    case appleMusic
//    case spotify
//}
#Preview {
    iPhoneContentView()
}
