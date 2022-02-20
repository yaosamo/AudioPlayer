//
//  Playlist.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/29/22.
//

import Foundation
import SwiftUI


struct Books: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var PlayerStatus: AudioPlayerStatus
    @State var playlist: Playlist
    @State var books: Array<Book>?
    @State private var presentImporter: Bool = false
    // sorting books by name
    let booksorting =  NSSortDescriptor(key: "name", ascending: true)
    
    var body: some View {
        // The sample audio player.
        let audioplayer = AudioPlayer(PlayerStatus: PlayerStatus)
        // Converting NSSet of playlists book to Array and aplying sorting by name
        let books = playlist.book!.sortedArray(using: [booksorting]) as! [Book]
        
        ZStack(alignment: .trailing) {
            Text(playlist.name!)
                .frame(width: 400, height: 60, alignment: .trailing)
                .rotationEffect(.degrees(-90))
                .font(.system(size: 100, weight: .medium, design: .rounded))
                .padding(.trailing, -190)
                .padding(.top, 100)
                .foregroundColor(Color(red: 0.88, green: 0.83, blue: 0.68))

        List {
            ForEach(books) { book in
                Button("\(book.name ?? "")", action: {
                    let CurrentItemID = book.id
                    // Pass array of all audiobooks to our playlist
                    PlayerStatus.currentPlaylist = books
                    PlayerStatus.currentlyPlayingID = CurrentItemID
                    audioplayer.PlayManager(bookmarkData: book.urldata!)
                    let _ = print("Now playing book at:", audioplayer.CurrentPlayingIndex())
                })
                    .font(.system(size: 24, design: .rounded))
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
        
        //        .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.mp3], onCompletion: function)
        //        func importImage(_ res: Result<URL, Error>) {
        //                do{
        //                    let fileUrl = try res.get()
        //                    print(fileUrl)
        //
        //                    guard fileUrl.startAccessingSecurityScopedResource() else { return }
        //                    if let imageData = try? Data(contentsOf: fileUrl),
        //                       let image = UIImage(data: imageData) {
        //                        self.images[index] = image
        //                    }
        //                    fileUrl.stopAccessingSecurityScopedResource()
        //                } catch{
        //                    print ("error reading")
        //                    print (error.localizedDescription)
        //                }
        //            }
        
        .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.mp3]) { result in
            switch result {
            case .success(let url):
                
                // Start accessing secured url
                let StartAccess = url.startAccessingSecurityScopedResource()
                defer {
                    // Must stop accessing once stop using
                    if StartAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }
                addBook(url: url)
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    private func addBook(url: URL) {
        withAnimation {
            // Creating new book
            let newBook = Book(context: viewContext)
            let _ = print("---- Access Granted?", url.startAccessingSecurityScopedResource())
            // Getting bookmarkData of the URL
            let bookmarkData = try? url.bookmarkData()
            let shortURL = url.deletingPathExtension().lastPathComponent
            newBook.name = "\(shortURL)"
            // Save bookmarkURL into CoreData
            newBook.urldata = bookmarkData
            // Specifiying parent item in CoreData
            newBook.origin = playlist.self
            try? viewContext.save()
            let _ = print("new book created")
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
