//
//  ProgramViewModel.swift
//  Better Now Playing
//
//  Created by Mason Likens on 10/17/24.
//

import UIKit

final class ProgramViewModel: ObservableObject {
    private(set) var connectivityProvider: ConnectionProvider
    
    init(connectivityProvider: ConnectionProvider) {
        self.connectivityProvider = connectivityProvider
        self.connectivityProvider.connect()
        //self.currentMusicData = viewModel.connectivityProvider.currentMusicData
    }
}
