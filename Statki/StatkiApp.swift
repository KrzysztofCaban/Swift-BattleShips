//
//  StatkiApp.swift
//  Statki
//
//  Created by Krzysztof Caban on 07/01/2024.
//

import SwiftUI

@main
struct StatkiApp: App {
    @StateObject private var game = Game(numCols: 8, numRows: 8)
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(game)
        }
    }
}
