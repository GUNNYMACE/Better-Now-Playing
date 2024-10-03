//
//  ContentView.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/2/24.
//

import SwiftUI
import MusicKit
import MediaPlayer



struct ContentView: View {
    @State var musicAuth = MusicKit.MusicAuthorization.currentStatus
    @State var currentSongTitle = ""
    @State var currentSongArtist = ""
    var body: some View {
        
        
        if (musicAuth == .authorized) {
            Text(currentSongTitle)
            Text(currentSongArtist)
        } else {
            Text("Not Authorized")
        }
        
        
        Button {
            print("Trigger")
            Task {
                await MusicKit.MusicAuthorization.request()
            }
            if MusicKit.MusicAuthorization.currentStatus == .authorized {
                print("Authorized")
            } else {
                print("Not Authorized")
            }
            currentSongTitle  = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.title)!
            currentSongArtist = (MPMusicPlayerController.systemMusicPlayer.nowPlayingItem?.artist)!
        } label: {
            Text("Get Current Apple Music Song")
        }
        
    }
}

#Preview {
    ContentView()
}
