//
//  ContentView.swift
//  Better Now Playing Watch App
//
//  Created by Mason Likens on 10/2/24.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @StateObject var viewModel = ProgramViewModel(connectivityManager: ConnectivityManager())
    var connect = ConnectivityManager()
    @State var currentSong: String = "-"
    @State var currentArtist: String = "Please Update"
    @State var currentAlbum: String = "-"
    
    let userDefaults = UserDefaults(suiteName: "group.com.betternowplaying.datashare")
    
    var body: some View {
        Text("BNP")
            .bold()
            .font(.title2)
            .padding()
            
        VStack {
            Text(currentSong)
            Text(currentArtist)
            Text(currentAlbum)
            Button(action: {
                viewModel.connectivityManager.connect()
                if (viewModel.connectivityManager.currentMusicData.count > 0) {
                    currentSong = viewModel.connectivityManager.currentMusicData[0].title ?? "-"
                    currentArtist = viewModel.connectivityManager.currentMusicData[0].artist ?? "No Data"
                    currentAlbum = viewModel.connectivityManager.currentMusicData[0].album ?? "-"
                    if let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.betternowplaying.datashare") {
                        let fileURL = sharedContainerURL.appendingPathComponent("MMDData.json")
                        do {
                            let data = try JSONEncoder().encode(viewModel.connectivityManager.currentMusicData[0])
                            try data.write(to: fileURL)
                        } catch {
                            fatalError("Error encoding JSON: \(error)")
                        }
                    }
                } else {
                    currentSong = "No Data"
                    currentArtist = "Please send data"
                    currentAlbum = "from iPhone first."
                }
                
                WidgetCenter.shared.reloadAllTimelines()
            }, label: {Text("Update")})
        }
    }
}
#Preview {
    ContentView()
}
