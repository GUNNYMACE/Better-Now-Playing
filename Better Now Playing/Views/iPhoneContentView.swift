//
//  ContentView.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/2/24.
//

import SwiftUI
import MusicKit
import MediaPlayer
import WatchConnectivity

struct iPhoneContentView: View {
    //MARK: Main Vars
    enum CurrentMusicPlayer {
        case none
        case appleMusic
        case spotify
    }
    
    @State var currentPlayer: CurrentMusicPlayer = .none
    @State var currentSongName: String = "-"
    @State var currentSongArtist: String = "Press the Refresh Button"
    @State var currentSongAlbum: String = "-"
    @State var currentSongArtwork: UIImage = UIImage(named: "MusicBlank")!
    @StateObject var apPlayer: AppleMusicPlayer = AppleMusicPlayer()
    var spotifyPlayer: SpotifyManager = SpotifyManager()
    
    let viewModel = ProgramViewModel(connectivityManager: ConnectivityManager())
    let connect = ConnectivityManager()
    
    
    
    //Main Body
    var body: some View {
        TabView() {
            //MARK: Currently Playing Page
            Tab("Currently Playing", systemImage: "music.note.list") {
                Image(uiImage: currentSongArtwork)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 350, height: 350)
                        
                Group {
                    Text(currentSongName)
                    Text(currentSongArtist)
                    Text(currentSongAlbum)
                }
                .font(.title3)
                
                Button("Refresh", action: {
                    if (currentPlayer == .appleMusic) {
                        apPlayer.updateCurrentSong()
                        currentSongName = apPlayer.currentSongName ?? "-"
                        currentSongArtist = apPlayer.currentSongArtist ?? "No Song Currently Playing"
                        currentSongAlbum = apPlayer.currentSongAlbum ?? "-"
                        currentSongArtwork = apPlayer.currentSongArtwork ?? UIImage(named: "MusicBlank")!
                    } else if (currentPlayer == .spotify) {
                        //FIXME: Fix the return method for authing spotify, its not activating.
                    } else {
                        print("None Selected")
                    }
                })
                .padding(.top, 5.0)
                .font(.title3)
                
                Button("Send to Watch", action: {
                    viewModel.connectivityManager.connect()
                    viewModel.connectivityManager.sendMusicData(title: currentSongName, artist: currentSongArtist, album: currentSongAlbum)
                })
                .font(.title3)
                
                //Gauge(value: 0.5, in: 0...1) {}
            }
            //MARK: Widget Select Page
            Tab("Widgets", systemImage: "widget.small") {
                Text("Not implemented yet")
            }
            
            //MARK: Settings Page
            Tab("Settings", systemImage: "gear") {
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
                            //.disabled(spotifyPlayer.currentAuthStatus != .authorized)
                        }
                    }
                    
                    //MARK: Auth Section
                    Section {
                        Button(action: {
                            print("Auth AP Music")
                            apPlayer.attemptAuth()
                            print(apPlayer.currentAuthStatus)
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
                        }) {
                            HStack(alignment: .center) {
                                Text("Authorize Spotify")
                                //if (spotifyPlayer.currentAuthStatus == .authorized) {
                                //    Image(systemName: "checkmark")
                                //}
                            }
                            
                        }
                        //.disabled(spotifyPlayer.currentAuthStatus != .unauthorized)
                    }
                }
            }
        }
    }
}

#Preview {
    iPhoneContentView()
}
