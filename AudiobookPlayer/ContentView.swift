//
//  ContentView.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/13/22.
//

import SwiftUI
import CoreData
import AVKit

class AudioPlayerStatus: ObservableObject {
    @Published var playing = false
}


struct ContentView: View {
    @StateObject var PlayerStatus = AudioPlayerStatus()

    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack {
            Playlists(PlayerStatus: PlayerStatus)
            Player(PlayerStatus: PlayerStatus)
        }
        .background(.black)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
