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
    @Published var speaker = ""
    @Published var bookname : String?
    @Published var playbackTime = "00:00:00"
    @Published var bookPlaybackWidth = CGFloat(0)
    @Published var playerIsSeeking = false
    @Published var currentBookLenght : Double?
    @Published var currentlyPlayingIndex : Int?
    @Published var currentlyPlayingID : ObjectIdentifier?
    @Published var currentPlaylist : Array<Book>?
}

struct ContentView: View {
    @StateObject var PlayerStatus = AudioPlayerStatus()
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack {
            Playlists(PlayerStatus: PlayerStatus)
            PlayerUI(PlayerStatus: PlayerStatus)
        }
        .background(.black)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
