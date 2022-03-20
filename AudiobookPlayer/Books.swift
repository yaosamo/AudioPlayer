//
//  Playlist.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/29/22.
//

import Foundation
import SwiftUI
import AVFoundation



let inactive = Color(red: 0.40, green: 0.42, blue: 0.45)
let active = Color(red: 0.99, green: 0.99, blue: 0.99)
// sorting books by name
let booksorting =  NSSortDescriptor(key: "name", ascending: true)


public extension Button {
    func BookStyle() -> some View {
        self
            .font(.system(size: 24, design: .rounded))
            .foregroundColor(active)
            .padding(.bottom, 8)
    }
}


struct Books: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var playerEngine: AudioPlayerStatus
    
    var playlist: Playlist
    var allPlaylists: FetchedResults<Playlist>
    
    @State var playlistName: String
    @State private var presentImporter: Bool = false
    @State private var showingPopover = false
    @State private var showConfirmation = false
    
    var body: some View {
        // Converting NSSet of playlists book to Array and aplying sorting by name
        let books = playlist.book?.sortedArray(using: [booksorting]) as! [Book]?
        
        ZStack(alignment: .trailing) {
            
            darkColor.edgesIgnoringSafeArea(.all)
            
            Text(playlist.name ?? "")
                .frame(width: 600, height: 60, alignment: .trailing)
                .rotationEffect(.degrees(-90))
                .font(.system(size: 100, weight: .medium, design: .rounded))
                .padding(.trailing, -296)
                .padding(.top, 200)
                .foregroundColor(giveColor(allPlaylists, playlist))
            
            List {
                if books != nil {
                    ForEach(books!) { book in
                        Button(action: {
                            let URL = playerEngine.restoreURL(bookmarkData: book.urldata!)
                            // Pass array of all audiobooks to our playlist
                            playerEngine.currentPlaylist = books
                            playerEngine.allPlaylists = allPlaylists
                            playerEngine.currentPlaylistID = playlist.id
                            playerEngine.currentBookID = book.id
                            playerEngine.bookname = book.name
                            playerEngine.PlayManager(play: URL)
                            playerEngine.SavePlay()
                            let _ = print("Now playing book at:", playerEngine.CurrentBookIndex())
                            
                        }, label: {
                            
                            VStack(alignment: .leading) {
                                Text(book.name ?? "Unknown name")
                                    .MainFont(Size: 24, Weight: .regular)
                                    .frame(height: 24, alignment: .leading)
                                    .foregroundColor(book.id == playerEngine.currentBookID ? active : inactive)
                                
                                Text(book.author ?? "Unknown author")
                                    .font(.system(size: 16, design: .rounded))
                                    .foregroundColor(inactive)
                            }
                        })
                        .padding(.bottom, 8)
                    }
                    .onDelete(perform: { IndexSet in
                        deleteBookItems(offsets: IndexSet, books: books!)
                    })
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red: 0, green: 0, blue: 0, opacity: 0.0))
                }
            } // List
            .listStyle(.inset)
            
            .toolbar {
                    Menu {
                        Button("Import from iCloud", action: {presentImporter.toggle()})
                        Button("Rename playlist", action: {showingPopover.toggle()})
                        Button("Delete playlist", role: .destructive, action: { showConfirmation.toggle()})
                    }
                label: { Label("Menu", systemImage: "ellipsis")
                        .frame(width: 40, height: 48)
                }
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
                        .foregroundColor(giveColor(allPlaylists, playlist))
                        .multilineTextAlignment(.center)
                    Spacer()
                    Button(action: {
                        renamePlaylist(playlist: playlist)
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
                
                .confirmationDialog("Would you like to delete this playlist? \n It will be deleted on all devices", isPresented: $showConfirmation, titleVisibility: .visible) {
                    Button("Delete", role: .destructive) {
                        deletePlaylist()
                        showConfirmation = false
                    }
                    
                    Button("Cancel") {
                        showConfirmation = false
                    }
                }
            }
            if books!.count < 1 {
                HStack {
                    Text("Import first book")
                        .MainFont(Size: 24, Weight: .regular)
                    Image(systemName: "arrow.up")
                }
                .offset(x: -28, y: -UIScreen.main.bounds.height / 3.5)
            }

        } // Zstack
        
        .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.mp3], allowsMultipleSelection: true, onCompletion: importBooks)
    }
    
    // Updating item funcion
    private func renamePlaylist(playlist: Playlist) {
        let newName = playlistName
        viewContext.performAndWait {
            playlist.name = newName
            try? viewContext.save()
        }
    }
    
    
    private func importBooks(_ res: Result<[URL], Error>) {
        do {
            let urls = try res.get()
            for bookIndex in 0...urls.count-1 {
                let bookURL = urls[bookIndex]
                let StartAccess = bookURL.startAccessingSecurityScopedResource()
                addBook(url: bookURL)
                if StartAccess {
                    bookURL.stopAccessingSecurityScopedResource()
                }
            }
        } catch {
            print(error)
        }
    }
    
    
    private func addBook(url: URL) {
        let meta = metaData(url: url)
        
        if playlist.id == playerEngine.currentPlaylistID {
            playerEngine.Stop()
            playerEngine.abortPlay()
        }
        
        withAnimation {
            // Creating new book
            let newBook = Book(context: viewContext)
            // Getting bookmarkData of the URL
            let bookmarkData = try? url.bookmarkData()
            newBook.name = meta.bookTitle
            newBook.author = meta.bookAuthor
            // Save bookmarkURL into CoreData
            newBook.urldata = bookmarkData
            // Specifiying parent item in CoreData
            newBook.origin = playlist.self
            try? viewContext.save()
            print("new book created")
        }
    }
    
    private func deletePlaylist() {
        if playlist.id == playerEngine.currentPlaylistID {
            playerEngine.Stop()
            playerEngine.abortPlay()
        }
        
        let deletingplaylistIndex = allPlaylists.firstIndex(where: { $0.id == playlist.id} )!
        let indexSet = IndexSet(integer: deletingplaylistIndex)
        
        // check if deleted index is less than the one that saved, update saved index -1.
        print("deleting playlist at:", deletingplaylistIndex)
        if deletingplaylistIndex < playerEngine.restoreplaylistIndex ?? 0 {
            let savedIndex = playerEngine.restoreplaylistIndex!
            playerEngine.restoreplaylistIndex = savedIndex - 1
            print("saved new playlist index at:", playerEngine.restoreplaylistIndex)
        }
        
        withAnimation {
            indexSet.map { allPlaylists[$0] } .forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    
    private func deleteBookItems(offsets: IndexSet, books: Array<Book>) {
        withAnimation {
            offsets.map { books[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}



func metaData(url: URL) -> (bookTitle: String, bookAuthor: String) {
    let asset = AVAsset(url: url)
    
    // return values
    var bookTitle = ""
    var bookAuthor = ""
    
    // Refactor https://developer.apple.com/documentation/avfoundation/media_assets_and_metadata/retrieving_media_metadata
    
    // check if meta is not empty getting meta for Title and artist
    if asset.commonMetadata.count > 0  {
        
        for info in asset.commonMetadata {
            if info.commonKey?.rawValue == "title" {
                let bookTitleraw = info.value as! String
                bookTitle = converter(raw: bookTitleraw)
            }
            if info.commonKey?.rawValue == "artist" {
                let bookAuthorraw = info.value as! String
                bookAuthor = converter(raw: bookAuthorraw)
            }
        }
        // if meta is empty assign title as file name & author to Unknown
    } else {
        bookTitle = url.deletingPathExtension().lastPathComponent
        print("Nothing found in data for Title & Author")
        bookAuthor = "Unknown author 🤷"
    }
    
    // converting cyrillic encoding 1251 if needed
    func converter(raw: String) -> String {
        var cleanData = ""
        let cp1252Data = raw.data(using: .windowsCP1252)
        let decoded = String(data: cp1252Data ?? Data(), encoding: .windowsCP1251)!
        // checking if decoded string was success
        if decoded.count > 0 {
            // return decoded
            cleanData = decoded
        } else {
            // return original
            cleanData = raw
            
        }
        return cleanData
    }
    
    return (bookTitle, bookAuthor)
}
