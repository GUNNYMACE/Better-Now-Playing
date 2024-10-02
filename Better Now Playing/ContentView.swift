//
//  ContentView.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/2/24.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    
    var body: some View {
        Button(action: handleMusicAuth) {
            Text("Test Prompt")
        }
    }
}

private func handleMusicAuth() {
    print("Trigger")
}

#Preview {
    ContentView()
}
