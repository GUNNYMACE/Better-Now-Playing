//
//  iPhoneContentView.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/2/24.
//
//  Main View for Better Now Playing
//

//Note: Old UI the app used to use.

/*

import SwiftUI
import MusicKit
import MediaPlayer
import WatchConnectivity

struct OldView: View {
    //MARK: Main Vars
    enum CurrentMusicPlayer {
        case none
        case appleMusic
        case spotify
    }
    
    @State var currentPlayer: CurrentMusicPlayer = .none {
        didSet {
            if currentPlayer == .spotify {
                refreshUI()
            }
        }
    }
    @State var currentSongName: String = "-"
    @State var currentSongArtist: String = "Press the Refresh Button"
    @State var currentSongAlbum: String = "-"
    @State var currentSongArtwork: UIImage = UIImage(named: "MusicBlank")!
    @StateObject var apPlayer: AppleMusicPlayer = AppleMusicPlayer()
    var spotifyPlayer: SpotifyManager = SpotifyManager()
    
    let viewModel = ProgramViewModel(connectivityManager: ConnectivityManager())
    let connect = ConnectivityManager()

    @State private var showSwitchAlert = false //FIXME: Turn back on
    @State private var showErrorActive = false
    
    //Main Body
    var body: some View {
        VStack{}
        .onOpenURL { url in
            spotifyPlayer.URLRecived(url)
        }
        .onReceive(NotificationCenter.default.publisher(for: .spotifyTrackUpdated)) { _ in
            currentPlayer = .spotify
            refreshUI()
        }
        .onReceive(NotificationCenter.default.publisher(for: .spotifyErrorOccurred)) { notification in
            showErrorActive = true
        }
        .alert(isPresented: $showSwitchAlert) {
            //MARK: Launch Spotify Alert
            Alert(
                title: Text("Launching Spotify"),
                message: Text("Launching the Spotify Controls requires a quick visit to the Spotify app. Would you like to do that?"),
                primaryButton: .default(Text("Launch Spotify")) {
                    print("Go For It")
                    spotifyPlayer.attemptAuth()
                    currentPlayer = .spotify
                    refreshUI()
                },
                secondaryButton: .cancel {
                    print("Canceled Spotify Auth, Switching to AP")
                    currentPlayer = .appleMusic
                    refreshUI()
                }
            )
        }
        TabView {
            currentlyPlayingTab.tabItem {
                Label("Currently Playing", systemImage: "music.note.list")
            }
            settingsTab.tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .alert(isPresented: $showErrorActive) {
            //MARK: Spotify Error Alert
            Alert(
                title: Text("Error With Spotify"),
                message: Text(spotifyPlayer.errorDetails!),
                primaryButton: .default(Text("Re-Launch Spotify")) {
                    print("Error - Reattempting")
                    spotifyPlayer.attemptAuth()
                    currentPlayer = .spotify
                    refreshUI()
                },
                secondaryButton: .cancel {
                    print("Canceled Spotify Auth, Switching to AP")
                    currentPlayer = .appleMusic
                    refreshUI()
                }
            )
        }
    }
    
    //MARK: Refresh Functions
    func refreshUI() {
        if (currentPlayer == .appleMusic) {
            apPlayer.updateCurrentSong()
            currentSongName = apPlayer.currentSongName ?? "-"
            currentSongArtist = apPlayer.currentSongArtist ?? "No Song Currently Playing"
            currentSongAlbum = apPlayer.currentSongAlbum ?? "-"
            currentSongArtwork = apPlayer.currentSongArtwork ?? UIImage(named: "MusicBlank")!
        } else if (currentPlayer == .spotify) {
            currentSongName = spotifyPlayer.currentTrackTitle ?? "-"
            currentSongArtist = spotifyPlayer.currentTrackArtist ?? "No Song Currently Playing"
            currentSongAlbum = spotifyPlayer.currentTrackAlbumName ?? "-"
            currentSongArtwork = spotifyPlayer.currentTrackImage ?? UIImage(named: "MusicBlank")!
        } else {
            print("None Selected")
        }
    }
    
    //MARK: Tab Views
    private var currentlyPlayingTab: some View {
        
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
            
            Button("Refresh (For AP)", action: {
                currentPlayer = .appleMusic
                refreshUI()
            })
            .padding(.top, 5.0)
            .font(.title3)
            
            Button("Send to Watch", action: {
//                viewModel.connectivityManager.connect()
//                viewModel.connectivityManager.sendMusicData(title: currentSongName, artist: currentSongArtist, album: currentSongAlbum)
            })
            .font(.title3)
        }
    }
    
    private var settingsTab: some View {
        VStack {
            Form {
                //MARK: Music Player Section
                Section {
                    Menu("Current Music Player: " + {
                        switch currentPlayer {
                        case .none:
                            return "None"
                        case .appleMusic:
                            return "Apple Music"
                        case .spotify:
                            return "Spotify"
                        }
                    }()) {
                        Button(action: {
                            currentPlayer = .appleMusic
                        }) {
                            if (currentPlayer == .appleMusic) {
                                Image(systemName: "checkmark")
                                Text("Apple Music")
                            } else {
                                Text("Apple Music")
                            }
                        }
                        .disabled(apPlayer.currentAuthStatus != .authorized)
                        
                        Button(action: {
                            currentPlayer = .spotify
                        }) {
                            if (currentPlayer == .spotify) {
                                Image(systemName: "checkmark")
                                Text("Spotify")
                            } else {
                                Text("Spotify")
                            }
                        }
//                        .disabled(spotifyPlayer.currentAuthStatus != .authorized)
                    }
                }
                
                //MARK: Auth Section
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
                    
                    Button(action: {
                        print("Auth Spotify")
                        spotifyPlayer.attemptAuth()
                        if (spotifyPlayer.currentAuthStatus == .authorized) {
                            currentPlayer = .spotify
                        }
                    }) {
                        HStack(alignment: .center) {
                            Text("Authorize Spotify")
                            if (spotifyPlayer.currentAuthStatus == .authorized) {
                                Image(systemName: "checkmark")
                            }
                        }
                        
                    }
                    .disabled(spotifyPlayer.currentAuthStatus != .notAuthorized)
                }
            }
        }
    }
}

struct ErrorDetails: Identifiable {
    let name: String
    let error: String
    let id = UUID()
}

#Preview {
    OldView()
}

*/
