//
//  ProgramObject.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/17/24.
//

import UIKit

public class MusicMetaData: NSObject, ObservableObject, NSSecureCoding, Codable {
    public static var supportsSecureCoding: Bool = true
    
    var id = UUID()
    public var title: String?
    public var artist: String?
    public var album: String?
    
    func initWithData(title: String, artist: String, album: String) {
        self.title = title
        self.artist = artist
        self.album = album
    }
    
    #if os(iOS)
    func setDataAP(_ AP: AppleMusicPlayer) {
        self.title = AP.currentSongName
        self.album = AP.currentSongAlbum
        self.artist = AP.currentSongArtist
    }
//    func setDataSP(_ SP: SpotifyPlayer) {
//        self.title = SP.currentSongName
//        self.album = SP.currentSongAlbum
//        self.artist = SP.currentSongArtist
//
//        //FIXME: ADD CONVERSION THIGNSOIGNSOGn
//    }
    #endif
    
    public required convenience init?(coder: NSCoder) {
        guard let title = coder.decodeObject(forKey: "title") as? String,
              let artist = coder.decodeObject(forKey: "artist") as? String,
              let album = coder.decodeObject(forKey: "album") as? String
        else { return nil }
        
        self.init(songTitle: title, songArtist: artist, songAlbumTitle: album)
        //self.initWithData(title: title as String, artist: artist as String, album: album as String)
    }
    
    init(songTitle: String, songArtist: String, songAlbumTitle: String) {
        title = songTitle
        artist = songArtist
        album = songAlbumTitle
        super.init()
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: "title")
        coder.encode(self.artist, forKey: "artist")
        coder.encode(self.album, forKey: "album")
    }
    
    public func getData() -> [String] {
        return [self.title!, self.artist!, self.album!]
    }
    
//    public override var description: String {
//        return "\()"
//    }
}
