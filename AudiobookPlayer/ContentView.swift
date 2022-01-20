//
//  ContentView.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/13/22.
//

import SwiftUI
import CoreData
import AVKit


extension Text {

    func MainFont(_ Size : CGFloat) -> some View {
        
        self.font(.system(size: Size, weight: .medium, design: .rounded))
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    init() {
           UITableView.appearance().backgroundColor = .clear
       }
    
    var body: some View {
        VStack {
            Playlist()
            Player()
            
        }
        .background(.black)
    }
}


struct Playlist: View {
    let playlists = ["Marusya", "Brands", "Billionair", "MDS"]
 
    var body: some View {

        NavigationView {
            List {
            ForEach(playlists, id: \.self) { item in
                NavigationLink(destination: Text("Internal")) {
                Text(item)
                        .MainFont(32)
                        .frame(height: 48)
                        .navigationBarHidden(true)
                            }
                        }
            .foregroundColor(.white)
            .listRowBackground(Color.black)
                }
            .background(.black)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
