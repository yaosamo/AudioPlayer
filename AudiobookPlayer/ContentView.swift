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
    let colour: UIColor
}

struct Playlist: View {
    let playlists = ["Marusya", "Brands", "Billionair", "MDS"]
    var biege = UIColor(red: 0.88, green: 0.83, blue: 0.68, alpha: 1.00)
    let lightblue = UIColor(red: 0.62, green: 0.78, blue: 0.78, alpha: 1.00)
    let purple = UIColor(red: 0.40, green: 0.45, blue: 0.94, alpha: 1.00)
    let brown = UIColor(red: 0.69, green: 0.33, blue: 0.22, alpha: 1.00)
    var colorslist : [Color] = [Color(red: 0.88, green: 0.83, blue: 0.68), Color(red: 0.62, green: 0.78, blue: 0.78), Color(red: 0.40, green: 0.45, blue: 0.94), Color(red: 0.69, green: 0.33, blue: 0.22)]
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.name, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    
    var body: some View {
//        HStack {
//            Button(action: addPlaylist) {
//                Image(systemName: "plus")
//                    .foregroundColor(.white)
//                    .font(.system(size: 32.0))
//                    .padding([.top, .leading], 40)
//            }
//            Spacer()
//        }
        
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    NavigationLink(destination: Text("Internal")) {
                        Text(item.name!)
                            .MainFont(32)
                            .frame(height: 48)
                            .foregroundColor(colorslist[0])
//                            .navigationBarHidden(true)
                    }
                }
                .onDelete(perform: deleteItems)
                .foregroundColor(.white)
                .listRowBackground(Color.black)
            }
            .background(.black)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                        Button(action: addPlaylist) {
                                            Image(systemName: "plus")
                                                .foregroundColor(.white)
                                                .font(.system(size: 24.0))
                                                .padding([.leading, .top], 16)
                                        }
                            }
                        }
        }
    }
    
    private func addPlaylist() {
        withAnimation {
            let newPlaylist = Item(context: viewContext)
            newPlaylist.name = "New Playlist"
            newPlaylist.color = ""
            try? viewContext.save()
            let _ = print("new playlist created")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
