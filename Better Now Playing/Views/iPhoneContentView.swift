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
    @State var musicAuth = MusicKit.MusicAuthorization.currentStatus
    @State var currentSongName: String = ""
    @State var currentSongArtist: String = ""
    @State var currentSongAlbum: String = ""
    
    @State var buttonText: String = (MusicKit.MusicAuthorization.currentStatus == .authorized) ? "Check & Set Apple Music Song Data" : "Tap to Authorize";
    
    let viewModel = ProgramViewModel(connectivityProvider: ConnectionProvider())
    let connect = ConnectionProvider()
    
    var body: some View {
        if musicAuth == .authorized {
            Text(currentSongName)
            Text(currentSongArtist)
            Text(currentSongAlbum)
        } else {
            Text("Not Authorized")
        }
        
        Button(action: {
            print("Checking Apple Music Authorization")
            Task {
                await MusicKit.MusicAuthorization.request()
            }
            if (musicAuth == .authorized) {
                currentSongName  = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.title)!
                currentSongArtist = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.artist)!
                currentSongAlbum = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.albumTitle)!
                
                viewModel.connectivityProvider.connect()
                viewModel.connectivityProvider.sendMusicData(title: currentSongName, artist: currentSongArtist, album: currentSongAlbum)
            }
        }) {
            Text(buttonText)
        }
    }
}

//@State var musicAuth = MusicKit.MusicAuthorization.currentStatus
//await MusicKit.MusicAuthorization.request()

#Preview {
    iPhoneContentView()
}
