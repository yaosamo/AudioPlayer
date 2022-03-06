//
//  AudiobookPlayerApp.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/13/22.
//

import SwiftUI

@main
struct AudiobookPlayerApp: App {
    @StateObject private var playerEngine = AudioPlayerStatus()

    
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(.dark)
                .environmentObject(playerEngine)
        }
    }
}
