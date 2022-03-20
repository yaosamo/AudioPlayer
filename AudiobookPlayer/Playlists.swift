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
    
    var allplaylists: FetchedResults<Playlist>
    @State private var showingPopover = false
    @State private var playlistName = "Playlist"
    @State private var readytoRestore = true
    @State private var newPlaylistIndex = 0
    
    
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
                        .listRowSeparator(.hidden)

                    
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
                        ZStack(alignment: .topLeading) {
                            NavigationLink(destination: Books(playlist: playlist, allPlaylists: allplaylists, playlistName: playlist.name!).environmentObject(playerEngine))  {
                                EmptyView()
                            }
                            .opacity(0.0)
                            .buttonStyle(PlainButtonStyle())
                            
                            HStack {
                                Text(playlist.name ?? "Noname")
                                    .MainFont(Size: 40, Weight: .regular)
                                    .frame(height: 48)
                                    .foregroundColor(giveColor(allplaylists, playlist))
                                    .navigationBarHidden(true)
                                    .padding(.bottom, 8)
                                
                            }
                        } // allplaylists ForEach
                        .listRowBackground(darkColor)
                        .listRowSeparator(.hidden)
                    }
                    
                }
                .listStyle(.inset)
                .onAppear {
                    playerEngine.allPlaylists = allplaylists
                    print("all playlists added")
                    if saveTorestore() {
                        playerEngine.restorePlay()
                        readytoRestore = false
                    }
                }
            }
        }
    }
    
    
    private func saveTorestore() -> Bool {
        var answer = false
        // trust me you don't want to fuck with this
        if (playerEngine.restorebookIndex != nil) && (playerEngine.restoreplaylistIndex != nil) && readytoRestore {
            if (playerEngine.restoreplaylistIndex! <= allplaylists.count-1) {
                if (playerEngine.restorebookIndex! <= allplaylists[playerEngine.restoreplaylistIndex!].book!.count) {
                    answer = true
                }
            }
        }
        return answer
    }
    
    
    private func addPlaylist(name: String) {
        withAnimation {
            let newPlaylist = Playlist(context: viewContext)
            newPlaylist.name = name
            try? viewContext.save()
            
            // check if created playlist's index is less than the one that saved, update saved index +1.
            let newIndex = allplaylists.firstIndex(where: { $0.id == newPlaylist.id} )!
            print("creating playlist at:", newIndex)
            
            if newIndex <= playerEngine.restoreplaylistIndex ?? 0 {
                let savedIndex = playerEngine.restoreplaylistIndex!
                playerEngine.restoreplaylistIndex = savedIndex + 1
                print("saved new playlist index at:", playerEngine.restoreplaylistIndex)
            }
            
            
            let _ = print("new playlist created")
        }
    }
}

func giveColor(_ allplaylists: FetchedResults<Playlist>, _ playlist: Playlist) -> Color {
    let currentID = allplaylists.firstIndex(of: playlist)!
    if currentID <= colorslist.count-1 {
        let color = colorslist[currentID]
        return color
    } else {
        return colorslist[.random(in: 0...colorslist.count-1)]
    }
    
}
