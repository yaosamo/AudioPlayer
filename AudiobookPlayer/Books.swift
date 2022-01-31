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
    @State var urlPreview: URL
    @State var item: Item
//    @State private var document: InputDoument = InputDoument(input: "")
      @State private var presentImporter: Bool = false
    var body: some View {
        Text("This is url for this book: \(urlPreview)")
        
        Button {presentImporter = true}
        
    label: { Label("Import book", systemImage: "square.and.arrow.down")}
    .fileImporter(isPresented: $presentImporter, allowedContentTypes: [.mp3]) { result in
                switch result {
                case .success(let url):
                    print(url)
                
                    viewContext.performAndWait {
                        item.url = url
                }
                    try? viewContext.save()
                    let _ = print("url added")
                    
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
