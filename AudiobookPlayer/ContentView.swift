//
//  ContentView.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/13/22.
//

import SwiftUI
import CoreData
import AVKit

class UserProgress: ObservableObject {
    @Published var score = false
    @Published var playing = false
}


struct ContentView: View {
//    @StateObject var progress = UserProgress()

    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        VStack {
           
            Playlists()
        }
        .background(.black)
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
