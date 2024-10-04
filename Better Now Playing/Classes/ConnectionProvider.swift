//
//  ConnectionProvider.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/17/24.
//

import UIKit
import WatchConnectivity

class ConnectionProvider: NSObject, WCSessionDelegate {
    private let session: WCSession
    var currentMusicData: [MusicMetaData] = []
    var recivedMusicMetaData: [MusicMetaData] = []
    var lastMessage: CFAbsoluteTime = 0
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        
#if os(iOS)
        print("Connect provider init on phone")
#elseif os(watchOS)
        print("Connect provider init on watch")
#endif
        
        self.connect()
    }
    
    func connect() {
        guard WCSession.isSupported() else{
            print("WCSession is not supported")
            return
        }
        
        session.activate()
    }
    
    func send(message: [String: Any]) -> Void {
        session.sendMessage(message, replyHandler: nil) { (error) in
            print("~Send Error: " + error.localizedDescription)
        }
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        #if os(iOS)
        print("Connected - iOS")
        #elseif os(watchOS)
        print("Connected - Watch")
        #endif
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif

//    func initFakeDetails() {
//        programs.removeAll()
//        let progObj = ProgramObject()
//        progObj.initWithData(title: "Title of BNP", speaker: "Me", from: "Now", to: "Later", details: "Time to Game WOMP WOMP")
//        programs.append(progObj)
//        
//        let progObj2 = ProgramObject()
//        progObj2.initWithData(title: "2Title of BNP", speaker: "2Me", from: "2Now", to: "2Later", details: "2Time to Game WOMP WOMP")
//        programs.append(progObj2)
//        
//        let progObj3 = ProgramObject()
//        progObj3.initWithData(title: "3Title of BNP", speaker: "3Me", from: "3Now", to: "3Later", details: "3Time to Game WOMP WOMP")
//        programs.append(progObj3)
//        
//        let progObj4 = ProgramObject()
//        progObj4.initWithData(title: "4Title of BNP", speaker: "4Me", from: "4Now", to: "4Later", details: "4Time to Game WOMP WOMP")
//        programs.append(progObj4)
//        
//        NSKeyedArchiver.setClassName("ProgramObject", for: ProgramObject.self)
//        let programData = try! NSKeyedArchiver.archivedData(withRootObject: programs, requiringSecureCoding: true)
//        sendWatchMessage(programData)
//    }
    public func sendMusicData(title: String, artist: String, album: String) {
        currentMusicData.removeAll()
        
        let currentSong = MusicMetaData()
        currentSong.initWithData(title: title, artist: artist, album: album)
        currentMusicData.append(currentSong)
        
        NSKeyedArchiver.setClassName("MusicMetaData", for: MusicMetaData.self)
        let musicData = try! NSKeyedArchiver.archivedData(withRootObject: currentMusicData, requiringSecureCoding: true)
        sendWatchMessage(musicData)
    }
    
    func sendWatchMessage(_ msgData: Data) {
        let currentTime = CFAbsoluteTimeGetCurrent()
        
        if lastMessage + 0.5 > currentTime {
            print("Too Many Attempts")
            return
        }
        
        if (session.isReachable) {
            print("Sending message to watch")
            let message = ["musicIDData": msgData]
            session.sendMessage(message, replyHandler: nil)
        } else {
            print("WCSession is not reachable")
        }
        
        lastMessage = CFAbsoluteTimeGetCurrent()
    }

    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message GOT!")
        if (message["musicIDData"] != nil) {
            let newData = message["musicIDData"]
            NSKeyedUnarchiver.setClass(MusicMetaData.self, forClassName: "MusicMetaData")
            let loadedData = try! NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClasses: [MusicMetaData.self], from: newData as! Data) as? [MusicMetaData]
            self.recivedMusicMetaData = loadedData!
            print("data received")
            
        }
    }
    
    func getRecivedMusicMetaData() -> [MusicMetaData] {
        return recivedMusicMetaData
    }
}
