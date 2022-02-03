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
    
    @State var playlist: Playlist
    @State var books: Array<Book>
    @State private var presentImporter: Bool = false
    
    var body: some View {
        List {
        ForEach(books, id: \.self) { book in
       
                Button("\(book.name ?? "")", action: {
                    let _ = print("play me")
                    let playme = book.url
                    playSound(playNow: playme!)
                    player?.play()
                })
                .font(.system(size: 24, design: .rounded))
            }
        .onDelete(perform: deleteItems)
        .listRowSeparator(.hidden)
//        .listRowBackground(Color.black)
        }
        .listStyle(.inset)
//        .background(.black)
        
        Button {presentImporter = true}
        
    label: { Label("Import book", systemImage: "square.and.arrow.down")}
    .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.mp3]) { result in
        switch result {
        case .success(let url):
            print(url)
            
            let newBook = Book(context: viewContext)
            newBook.name = "\(url.lastPathComponent)"
            newBook.url = url
            newBook.origin = playlist.self
            
            try? viewContext.save()
            let _ = print("New book", newBook.name as Any)
            let _ = print("inside", newBook.origin as Any)
            
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


class ViewModel: ObservableObject {
    
    var readString = ""
    func viewFile(fileUrl: URL) {
        do {
            readString = try String(contentsOf: fileUrl)
        } catch {
            print("Error reading file")
            print(error.localizedDescription)
        }
        
        print("File contents: \(readString)")
    }
}
