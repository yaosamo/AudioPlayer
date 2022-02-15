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
    @State var books: Array<Book>
    @State private var presentImporter: Bool = false
    let sound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "song1", ofType: "m4a")!)


    var body: some View {
        
        // The sample audio player.
        let audioplayer = AudioPlayer()
        
        List {
            
            ForEach(books, id: \.self) { book in
                Button("\(book.name ?? "")", action: {
                    let CurrentItemID = book.id
                    // Pass array of all audiobooks to our playlist
                    PlayerStatus.currentPlaylist = books
                    PlayerStatus.currentlyPlayingID = CurrentItemID
                    audioplayer.PlayManager(bookmarkData: book.urldata!, PlayerStatus: PlayerStatus)
//                    let _ = print("Now playing book at:", audioplayer.CurrentPlayingIndex())
                    
                })
                    .font(.system(size: 24, design: .rounded))
            }
            .onDelete(perform: deleteItems)
            .listRowSeparator(.hidden)
        }
        .listStyle(.inset)
        .toolbar {
            Button {presentImporter.toggle()}
        label: { Label("Import book", systemImage: "square.and.arrow.down")}
        }
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
                // Creating new book
                let newBook = Book(context: viewContext)
                let _ = print("---- Access Granted?", url.startAccessingSecurityScopedResource())
                // Getting bookmarkData of the URL
                let bookmarkData = try? url.bookmarkData()
                newBook.name = "\(url.lastPathComponent)"
                // Save bookmarkURL into CoreData
                newBook.urldata = bookmarkData
                // Specifiying parent item in CoreData
                newBook.origin = playlist.self
                try? viewContext.save()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { books[$0] }.forEach(viewContext.delete)
            
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
