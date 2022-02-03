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
        
        ForEach(books, id: \.self) { book in
            HStack {
                Text("\(book.name!)")
                    .padding(.bottom, 2)
                Spacer()
            }
        }
        
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
