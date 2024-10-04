//
//  ContentView.swift
//  Better Now Playing Watch App
//
//  Created by Mason Likens on 10/2/24.
//

import SwiftUI



struct ContentView: View {
    @State var currentSongTitle: String = "-"
    @State var currentSongArtist: String = "No Current Song"
    @State var currentSongAlbum: String = "-"
    
    let viewModel = ProgramViewModel(connectivityProvider: ConnectionProvider())
    let connect = ConnectionProvider()
    
    var body: some View {
        Text("Better Now Playing")
            .bold()
            .font(.title2)
            .padding()
            
        VStack {
            Text(currentSongTitle)
            Text(currentSongArtist)
            Text(currentSongAlbum)
            
            Button(action: {
                viewModel.connectivityProvider.connect()
                let temp = viewModel.connectivityProvider.getRecivedMusicMetaData()[0]
                currentSongTitle = temp.getData()[0]
                currentSongArtist = temp.getData()[1]
                currentSongAlbum = temp.getData()[2]
            }, label: {Text("Update")})
        }
    }
}
#Preview {
    ContentView()
}
