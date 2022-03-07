//
//  Playlist.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/29/22.
//

import Foundation
import SwiftUI
import AVFoundation

enum PlayerStatuses {
    case playing
    case stopped
}

let inactive = Color(red: 0.40, green: 0.42, blue: 0.45)
let active = Color(red: 0.99, green: 0.99, blue: 0.99)


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
    
    @State var playlist: Playlist
    @State var books: Array<Book>?
    @State private var presentImporter: Bool = false
    // sorting books by name
    let booksorting =  NSSortDescriptor(key: "name", ascending: true)
    @State var CurrentBookIsOn = false
    
    var body: some View {
        // Converting NSSet of playlists book to Array and aplying sorting by name
        let books = playlist.book!.sortedArray(using: [booksorting]) as! [Book]
        
        ZStack(alignment: .trailing) {
            Text(playlist.name!)
                .frame(width: 600, height: 60, alignment: .trailing)
                .rotationEffect(.degrees(-90))
                .font(.system(size: 100, weight: .medium, design: .rounded))
                .padding(.trailing, -284)
                .padding(.top, 200)
                .foregroundColor(Color(red: 0.88, green: 0.83, blue: 0.68))
            
            List {
                ForEach(books) { book in
                    Button(action: {
                        let CurrentItemID = book.id
                        let URL = playerEngine.restoreURL(bookmarkData: book.urldata!)
                        // Pass array of all audiobooks to our playlist
                        playerEngine.currentPlaylist = books
                        playerEngine.currentlyPlayingID = CurrentItemID
                        playerEngine.bookname = book.name
                        playerEngine.PlayManager(play: URL)
                        let _ = print("Now playing book at:", playerEngine.CurrentPlayingIndex())
                        
                    }, label: {
                        
                        VStack(alignment: .leading) {
                            Text(book.name ?? "Unknown name")
                                .frame(height: 24, alignment: .leading)
                                .font(.system(size: 24, design: .rounded))
                                .foregroundColor(book.id == playerEngine.currentlyPlayingID ? active : inactive)
                            
                            Text(book.author ?? "Unknown author")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(inactive)
                        }
                    })
                        .padding(.bottom, 8)
                        .onAppear {
                            if book.id == playerEngine.currentlyPlayingID {
                                CurrentBookIsOn = true
                            }
                        }
                }
                .onDelete(perform: { IndexSet in
                    deleteItems(offsets: IndexSet, books: books)
                })
                .listRowSeparator(.hidden)
                .listRowBackground(Color(red: 0, green: 0, blue: 0, opacity: 0.0))
            } // List
            .listStyle(.inset)
            .toolbar {
                Button {presentImporter.toggle()}
            label: { Label("Import book", systemImage: "square.and.arrow.down")}
            }
        } // Vstack
        
        .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.mp3], allowsMultipleSelection: true, onCompletion: importBooks)
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
        withAnimation {
            // Creating new book
            let newBook = Book(context: viewContext)
            let _ = print("---- Access Granted?", url.startAccessingSecurityScopedResource())
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
    
    
    private func deleteItems(offsets: IndexSet, books: Array<Book>) {
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
