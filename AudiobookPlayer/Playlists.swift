//
//  Playlists.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 2/3/22.
//

import SwiftUI
import CoreData

public extension Text {
    func MainFont(Size : CGFloat, Weight : Font.Weight) -> some View {
        self.font(.system(size: Size, weight: Weight, design: .rounded))
    }
}


struct Playlists: View {
    
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
            ZStack {
                darkColor
                    .edgesIgnoringSafeArea(.all)
                    
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
                        .listRowBackground(darkColor)
                    
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
                                showingPopover = false
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
                    
                    ForEach(allplaylists) { playlist in
                        NavigationLink(destination: Books(playlist: playlist, playlistName: playlist.name!).environmentObject(playerEngine))  {
                            Text(playlist.name ?? "Noname")
                                .MainFont(Size: 40, Weight: .regular)
                                .frame(height: 48)
                                .foregroundColor(colorslist[0])
                                .navigationBarHidden(true)
                                .padding(.bottom, 8)
                        }
                    } // allplaylists ForEach
                    .onDelete(perform: deleteItems)
                    .listRowSeparator(.hidden)
                    .listRowBackground(darkColor)
                }
                .listStyle(.inset)
            }
        }
    }
    
    
    
    private func addPlaylist(name: String) {
        withAnimation {
            let newPlaylist = Playlist(context: viewContext)
            newPlaylist.name = name
            try? viewContext.save()
            let _ = print("new playlist created")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        // if currently playing book is in deleted playlist > refresh player UI
        playerEngine.Stop()
        playerEngine.abortPlay()
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
