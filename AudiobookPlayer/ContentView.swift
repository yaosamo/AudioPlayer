//
//  ContentView.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/13/22.
//

import SwiftUI
import CoreData
import AVKit

func hapticSuccess() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}

struct ContentView: View {
    @EnvironmentObject private var playerEngine: AudioPlayerStatus

    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    var body: some View {
        ZStack {
            borderColor
                .edgesIgnoringSafeArea(.all)
        VStack {
           
            Playlists()
                .environmentObject(playerEngine)

            PlayerUI()
                .padding(.top, -7)
                .environmentObject(playerEngine)
            }

        }
       


    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
