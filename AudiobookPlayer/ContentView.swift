//
//  ContentView.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/13/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        VStack {
            Playlist()
            Player()
            .frame(height: 320)
        }
    }
}


struct Player: View {
    var body: some View {
     
        Image(systemName: "play.fill")
                .resizable()
                .frame(width: 56, height: 56, alignment: .center)
                
        
    }
}

struct Playlist: View {
    let playlists = ["Marusya", "Brands", "Billionair"]
    
    var body: some View {
        NavigationView {
            List {
            ForEach(playlists, id: \.self) { item in
                NavigationLink(destination: Text("Internal")) {
                Text(item)
                }

                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
