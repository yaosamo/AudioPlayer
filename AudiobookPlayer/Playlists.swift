//
//  Playlists.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 2/3/22.
//

import SwiftUI
import CoreData



public extension Text {
    func MainFont(_ Size : CGFloat) -> some View {
        self.font(.system(size: Size, weight: .regular, design: .rounded))
    }
}

var addPlaylistUI: some View {
    Text("placeholder")
}


struct Playlists: View {
    var biege = UIColor(red: 0.88, green: 0.83, blue: 0.68, alpha: 1.00)
    let lightblue = UIColor(red: 0.62, green: 0.78, blue: 0.78, alpha: 1.00)
    let purple = UIColor(red: 0.40, green: 0.45, blue: 0.94, alpha: 1.00)
    let brown = UIColor(red: 0.69, green: 0.33, blue: 0.22, alpha: 1.00)
    var colorslist : [Color] = [Color(red: 0.88, green: 0.83, blue: 0.68), Color(red: 0.62, green: 0.78, blue: 0.78), Color(red: 0.40, green: 0.45, blue: 0.94), Color(red: 0.69, green: 0.33, blue: 0.22)]
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var playerEngine: AudioPlayerStatus

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Playlist.name, ascending: true)],
        animation: .default)
    private var allplaylists: FetchedResults<Playlist>
    @State private var showingPopover = false
    @State private var playlistName = "Playlist"
    
    
    var body: some View {
        
        NavigationView {
            List {
                // Add Playlist Button + pop-up
                Button(action: {
                    showingPopover.toggle()
                }, label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 32.0, weight: .regular, design: .rounded))
                        .padding([.top, .bottom], 16)
                })
                    .popover(isPresented: $showingPopover) {
                      
                        ZStack {
                            HStack {
                                Spacer()
                            Button(action: {
                                showingPopover = false
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(whiteColor)
                                    .font(.system(size: 24.0))
                                    .padding([.top, .trailing], 24)
                            })
                            }
                            
                            Text("Name")
                                .foregroundColor(whiteColor)
                                .padding(.top, 32)
                            
                        }
                        Spacer()
                        TextField("Name", text: $playlistName)
                            .font(.system(size: 64, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                        Spacer()
                        Button(action: {
                            addPlaylist(name: playlistName)
                        }, label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 24, weight: .medium, design: .rounded))
                                .foregroundColor(whiteColor)
                                .frame(width: 64, height: 64, alignment: .center)
                                .background(Color(red: 0.22, green: 0.23, blue: 0.24))
                                .clipShape(Circle())
                               
                        })
                            
                            .padding(.bottom, 32)
                    }
                    .listRowBackground(Color.black)
                
                ForEach(allplaylists) { playlist in
                    NavigationLink(destination: Books(playlist: playlist).environmentObject(playerEngine))  {
                        Text(playlist.name ?? "Noname")
                            .MainFont(40)
                            .frame(height: 48)
                            .foregroundColor(colorslist[0])
                            .navigationBarHidden(true)
                            .padding(.bottom, 8)
                    }
                } // allplaylists ForEach
                .onDelete(perform: deleteItems)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.black)
            }
            .listStyle(.inset)
            .background(.black)
        }
    }
    
    
    private func addPlaylist(name: String) {
        withAnimation {
            let newPlaylist = Playlist(context: viewContext)
            newPlaylist.name = name
            try? viewContext.save()
            let _ = print("new playlist created")
            showingPopover = false
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { allplaylists[$0] }.forEach(viewContext.delete)
            
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
