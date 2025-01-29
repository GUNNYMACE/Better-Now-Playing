//
//  AppleMusicPlayer.swift
//  Better Now Playing
//
//  Created by Mason Likens on 12/10/24.
//

import MusicKit
import MediaPlayer
import SwiftUI

class AppleMusicPlayer: ObservableObject, @unchecked Sendable {
    @Published var currentAuthStatus = MusicKit.MusicAuthorization.currentStatus
    @Published var currentSongName: String?
    @Published var currentSongArtist: String?
    @Published var currentSongAlbum: String?
    @Published var currentSongArtwork: UIImage?

    //MARK: attemptAuth()
    //Attempts to authorize access to Apple Music.
    func attemptAuth() {
        if currentAuthStatus != .authorized {
            print("AP Class Authorizing")
    
            Task {
                let status = await MusicKit.MusicAuthorization.request()
                DispatchQueue.main.async { [self] in
                    currentAuthStatus = status
                    
                    if currentAuthStatus == .authorized {
                        updateCurrentSong()
                    }
                }
            }
        }
    }
    
    //MARK: updateCurrentSong()
    //Updates the current song.
    func updateCurrentSong() {
        if (currentAuthStatus == .authorized) {
            let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
            
            if let nowPlayingItem = nowPlayingItem {
                currentSongName = nowPlayingItem.title
                currentSongArtist = nowPlayingItem.artist
                currentSongAlbum = nowPlayingItem.albumTitle
                currentSongArtwork = nowPlayingItem.artwork?.image(at: CGSize(width: 100, height: 100))
            }
        } else {
            print("Not authorized - updateCurrentSong()")
        }
    }
}
