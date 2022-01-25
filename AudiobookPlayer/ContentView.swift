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

struct ColorModel {
//    let name: String
    let colour: UIColor
}

struct Playlist: View {
    let playlists = ["Marusya", "Brands", "Billionair", "MDS"]
    var biege = UIColor(red: 0.88, green: 0.83, blue: 0.68, alpha: 1.00)
    let lightblue = UIColor(red: 0.62, green: 0.78, blue: 0.78, alpha: 1.00)
    let purple = UIColor(red: 0.40, green: 0.45, blue: 0.94, alpha: 1.00)
    let brown = UIColor(red: 0.69, green: 0.33, blue: 0.22, alpha: 1.00)
    var colorslist : [Color] = [Color(red: 0.88, green: 0.83, blue: 0.68), Color(red: 0.62, green: 0.78, blue: 0.78), Color(red: 0.40, green: 0.45, blue: 0.94), Color(red: 0.69, green: 0.33, blue: 0.22)]
    
    var body: some View {
        
        NavigationView {
            List {
                ForEach(playlists, id: \.self) { item in
                    let randomInt = Int.random(in: 0..<4)
                    NavigationLink(destination: Text("Internal")) {
                        Text(item)
                            .MainFont(32)
                            .frame(height: 48)
                            .navigationBarHidden(true)
                            .foregroundColor(colorslist[randomInt])
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
