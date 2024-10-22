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
    
    let viewModel = ProgramViewModel(connectivityManager: ConnectivityManager())
    let connect = ConnectivityManager()
    
    var body: some View {
        if musicAuth == .authorized {
            Image(systemName: "music.note.list")
            Text(currentSongName)
            Text(currentSongArtist)
            Text(currentSongAlbum)
        } else {
            Text("Not Authorized")
        }
        
        Button(buttonText) {
            buttonAction()
        }
    }
    
    func buttonAction() {
        print("Checking Apple Music Authorization")
        Task {
            await MusicKit.MusicAuthorization.request()
        }
        if (musicAuth == .authorized) {
            currentSongName  = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.title) ?? "No Value"
            currentSongArtist = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.artist) ?? "No Value"
            currentSongAlbum = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.albumTitle) ?? "No Value"
            
            viewModel.connectivityManager.connect()
            viewModel.connectivityManager.sendMusicData(title: currentSongName, artist: currentSongArtist, album: currentSongAlbum)
        }
    }
}

#Preview {
    iPhoneContentView()
}
