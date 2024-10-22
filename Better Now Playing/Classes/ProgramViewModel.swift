//
//  ProgramViewModel.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/17/24.
//

import UIKit
import SwiftUICore


final class ProgramViewModel: ObservableObject {
    private(set) var connectivityManager: ConnectivityManager
    
    init(connectivityManager: ConnectivityManager) {
        self.connectivityManager = connectivityManager
        self.connectivityManager.connect()
        //self.currentMusicData = viewModel.connectivityProvider.currentMusicData
    }
}
