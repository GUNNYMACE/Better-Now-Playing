//
//  ProgramObject.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/17/24.
//

import UIKit

public class MusicMetaData: NSObject, ObservableObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    let id = UUID()
//    @Published var title: String?
//    @Published var speaker: String?
//    @Published var from: String?
//    @Published var to: String?
//    @Published var details: String?
    @Published var title: String?
    @Published var artist: String?
    @Published var album: String?
    
    func initWithData(title: String, artist: String, album: String) {
        self.title = title
        self.artist = artist
        self.album = album
    }
    
    public required convenience init?(coder: NSCoder) {
        guard let title = coder.decodeObject(forKey: "title") as? String,
              let artist = coder.decodeObject(forKey: "artist") as? String,
              let album = coder.decodeObject(forKey: "album") as? String
        else { return nil }
        
        self.init()
        self.initWithData(title: title as String, artist: artist as String, album: album as String)
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: "title")
        coder.encode(self.artist, forKey: "artist")
        coder.encode(self.album, forKey: "album")
    }
    
    public func getData() -> [String] {
        return [self.title!, self.artist!, self.album!]
    }
}
