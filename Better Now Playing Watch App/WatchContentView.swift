//
//  WatchContentView.swift
//  Better Now Playing
//
//  Created by Mason Likens on 4/10/25.
//

import SwiftUI
import WatchKit
import WidgetKit

struct WatchContentView: View {
    //MARK: Vars
    //Background
    @State private var backgroundScale: CGFloat = 1.0
    //TopBar
    @State private var barColor: Color = .red
    @State private var barText: String = "Attempting to Connect..."
    @State private var textOffset: CGFloat = WKInterfaceDevice.current().screenBounds.width
    //Current Music Data
    @State var currentPlayer: currentMusicPlayer = .spotify
    @State var currentPlayerStatus: currentState = .offline
    @State var currentSongName: String = "-"
    @State var currentSongArtist: String = "Player Not Connected"
    @State var currentSongAlbum: String = "-"
    @State var currentSongArtwork: UIImage = UIImage(named: "MusicBlank")!
    //Buttons & Menu
    @State private var isMenuPresented: Bool = false
    
    @ObservedObject var manager = WatchConnectivityManager.shared
    
    var body: some View {
        ZStack {
            //MARK: Image Background
            Image(uiImage: currentSongArtwork)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: WKInterfaceDevice.current().screenBounds.width+30, height: WKInterfaceDevice.current().screenBounds.height+30)
                .blur(radius: 6)
                .clipped()
                .scaleEffect(backgroundScale)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 10.0)
                            .repeatForever(autoreverses: true)
                    ) {
                        backgroundScale = 1.1
                    }
                }
            
            
            
            
            
            //Foreground
            VStack {
                //MARK: Top Bar
                ZStack {
                    Rectangle()
                        .fill(barColor)
                        .frame(height: 40)
                    VStack {
                        Text(barText)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .font(.headline)
                             .lineLimit(1)
                            .offset(x: textOffset)
                            .onAppear {
                                withAnimation(
                                    Animation.linear(duration: 6.0)
                                        .repeatForever(autoreverses: false)
                                ) {
                                    textOffset = -WKInterfaceDevice.current().screenBounds.width
                                }
                            }
                        }
                    }
                    .padding(.top, 25 - 25)
                    .edgesIgnoringSafeArea(.top)
                    .frame(maxWidth: .infinity)
                Spacer()
                    .frame(height: 60)
                
                //Music
                Text(currentSongName)
                Text(currentSongArtist)
                Text(currentSongAlbum)
                Spacer()
                
                
                
                
                
                
                // obligatory random commment - colin j "cojo" reinacher
                //MARK: Bottom Buttons
                HStack {
                    // Left Menu Button
                    Button(action: {
                        isMenuPresented = true // Show the menu
                    }) {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.gray))
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $isMenuPresented) {
                        VStack {
                            Button("Spotify") {
                                if (currentPlayer != .spotify) {
                                    manager.requestDataOrChangePlayer(newPlayer: .spotify)
                                }
                                currentPlayer = .spotify
                                isMenuPresented = false
                                checkTopBarStatus()
                            }
                            .padding()
                            
                            Button("Apple Music") {
                                if (currentPlayer != .appleMusic) {
                                    manager.requestDataOrChangePlayer(newPlayer: .appleMusic)
                                }
                                currentPlayer = .appleMusic
                                isMenuPresented = false
                                checkTopBarStatus()
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(currentPlayer == .spotify ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                        //Color.blue.opacity(0.2)
                    }
                    Spacer()
                    
                    // Right Menu Button
                    Button(action: {
                        print("Refresh Button Tapped")
                        //FIXME: Do somthm
                        manager.requestDataOrChangePlayer(newPlayer: nil)
                        updateWidgetData()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.gray))
                    }
                    .buttonStyle(.plain)
                } 
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            } // End of Foreground
        } //End of ZStack
        .onAppear {
            
            // Register background tasks
            WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date().addingTimeInterval(15 * 60), userInfo: nil) { error in
                if let error = error {
                    print("Failed to schedule background refresh: \(error.localizedDescription)")
                } else {
                    print("Background refresh scheduled successfully")
                }
            }
            
            // Observe notifications for nowPlayingData updates
            NotificationCenter.default.addObserver(forName: .nowPlayingDataUpdated, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo {
                    currentSongName = userInfo["title"] as? String ?? "-"
                    currentSongArtist = userInfo["artist"] as? String ?? "Player Not Connected"
                    currentSongAlbum = userInfo["albumTitle"] as? String ?? "-"
                    currentSongArtwork = userInfo["albumArt"] as? UIImage ?? UIImage(named: "MusicBlank")!
                    
                    if let player = userInfo["currentPlayer"] as? CurrentMusicPlayer {
                        switch player {
                        case .appleMusic:
                            currentPlayer = .appleMusic
                        case .spotify:
                            currentPlayer = .spotify
                        case .none:
                            currentPlayer = .none
                        }
                        
                        print("PlayerFixPlease \(player)")
                    }
                    
                    if let status = userInfo["currentStatus"] as? currentState {
                        // Update the top bar or other UI elements based on the status
                        currentPlayerStatus = status
                    }
                    checkTopBarStatus()
                    updateWidgetData()
                }
            }
            
            //Request latest data
            manager.requestDataOrChangePlayer(newPlayer: nil)
            updateWidgetData()
        }
        .onDisappear {
            // Remove observer when the view disappears
            NotificationCenter.default.removeObserver(self, name: .nowPlayingDataUpdated, object: nil)
        }
    }
    
    
    
    
    
    //MARK: Functions
    //Updates the currently shown music.
    
    //Updates the current info
//    func updateInfo() {
//        if currentPlayer == .appleMusic {
//            //FIXME: Buh
//        } else if currentPlayer == .spotify {
//            if false {
////                currentSongName = spotifyPlayer.currentTrackTitle ?? "-"
////                currentSongArtist = spotifyPlayer.currentTrackArtist ?? "No Song Currently Playing"
////                currentSongAlbum = spotifyPlayer.currentTrackAlbumName ?? "-"
////                currentSongArtwork = spotifyPlayer.currentTrackImage ?? UIImage(named: "MusicBlank")!
//            } else {
//                print("Spotify is not connected")
//                defaultInfo()
//            }
//        } else {
//            print("None Selected")
//        }
//    }
    
    //Set info back to defaults without changing the current player.
    func defaultInfo() {
        currentSongName = "-"
        currentSongArtist = "Player Not Connected"
        currentSongAlbum = "-"
        currentSongArtwork = UIImage(named: "MusicBlank")!
    }
    
    //Top Bar Functions
    func checkTopBarStatus() {
        //Spotify
        //FIXME: Apply to Spotify
        if currentPlayer == .spotify {
            if currentPlayerStatus == .online {
                barColor = .green
                barText = "Spotify: Connected"
            } else if currentPlayerStatus == .offline {
                barColor = .red
                barText = "Spotify: Not Connected"
            } else {
                barColor = .red
                barText = "Spotify: Error"
            }
            
        //Apple Music
        } else if currentPlayer == .appleMusic {
            //FIXME: Apple Music
            barColor = .red
            barText = "Apple Music: Currently Unavailable"
        }
    }
    
    //Update Widget Function
    func updateWidgetData() {
        if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.betternowplaying.datashare") {
            let fileURL = sharedContainerURL.appendingPathComponent("MMDData.json")
            let imageFileURL = sharedContainerURL.appendingPathComponent("currentArtwork.jpeg")
            
            // Resize the image to 80x80
            let resizedArtwork = resizeImage(image: currentSongArtwork, targetSize: CGSize(width: 80, height: 80))
            
            // Save the resized image as a JPEG file
            if let imageData = resizedArtwork.jpegData(compressionQuality: 0.8) {
                do {
                    try imageData.write(to: imageFileURL)
                    print("Image saved successfully at \(imageFileURL)")
                } catch {
                    print("Error saving image: \(error)")
                }
            }
            
            let newData: [String: String] = [
                "title": currentSongName,
                "artist": currentSongArtist,
                "album": currentSongAlbum,
                "artworkPath": imageFileURL.lastPathComponent // Save the file name
            ]
            
            do {
                let data = try JSONEncoder().encode(newData)
                try data.write(to: fileURL)
                
                // Notify the widget to reload its timeline
                WidgetCenter.shared.reloadTimelines(ofKind: "AccessoryRectangularWidget")
            } catch {
                print("Error updating widget data: \(error)")
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine the scale factor to maintain aspect ratio
        let scaleFactor = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        let rect = CGRect(origin: .zero, size: newSize)
        
        // Render the resized image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}






//enum currentState {
//    case online
//    case offline
//    case unknown
//}

enum currentMusicPlayer {
    case spotify
    case appleMusic
    case none
}

#Preview {
    WatchContentView()
}
