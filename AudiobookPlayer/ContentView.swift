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
            .frame(height: 330)
        }
        .background(.black)
    }
}


struct Player: View {
    var body: some View {
        VStack {
            HStack {
            VStack(alignment: .leading){
                Text("Yaosamo Airpods")
                    .foregroundColor(Color(red: 0.93, green: 0.59, blue: 0.28))
                    .MainFont(12)
                Text("2010.03.10 Mazda")
                    .MainFont(24)
                    .foregroundColor(.white)
                Text("4:37:22")
                    .MainFont(12)
                    .foregroundColor(.white)
            }
            .padding(.leading, 32)
                Spacer()
            }
            
            
            ZStack {
            Capsule()
                .fill(Color.white).frame(height: 8)
                .padding(8)
            
            Capsule()
                .fill(Color.white).frame(height: 8)
                .padding(8)
            }
            .padding([.top, .bottom], 40)
            
            HStack {
                Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 38, height: 24    , alignment: .center)
                        .foregroundColor(.white)
                
            Spacer()
            Image(systemName: "play.fill")
                    .resizable()
                    .frame(width: 32, height: 44, alignment: .center)
                    .foregroundColor(.white)

                Spacer()
                Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 38, height: 24, alignment: .center)
                        .foregroundColor(.white)
            }
            .padding([.trailing, .leading], 72)
        }
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
