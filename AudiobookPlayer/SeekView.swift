//
//  SeekView.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 3/1/22.
//

import Foundation
import SwiftUI
import Combine


struct ViewOffsetKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct SeekView: View {
    @State private var seekingInProgress = false
    @State private var seekingTimer : Timer?
    @ObservedObject var PlayerStatus: AudioPlayerStatus
    @State private var offset = CGFloat.zero
    
    let center = UIScreen.main.bounds.width / 2
    
    var caret: some View {
        Rectangle()
            .fill(Color.white)
            .frame(width: 2, height: 56, alignment: .trailing)
        //compensate 2 for caret
            .padding([.leading], center-2)
    }
    
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders], content: {
                Section(header: caret) {
                    
                    // Book's Scroll
                    Rectangle()
                        .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .frame(width: PlayerStatus.bookPlaybackWidth, height: 48)
                    // Caret - playback position
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("scroll")).origin.x)
                        })
                    // added center to compensate padding
                        .onPreferenceChange(ViewOffsetKey.self) {
                            offset = $0+center
                        }
                }
            })
            // Trailing padding for whole lazy stack so caret and playback bounces off
                .padding([.trailing], center)
        }
        .coordinateSpace(name: "scroll")
        .onChange(of: offset, perform: { newValue in
            PlayerStatus.playerIsSeeking = true
            PlayerStatus.playbackTime = formatTimeFor(seconds: offset)
            
            // if player exist delete it
            if seekingTimer != nil {seekingTimer!.invalidate()
            }
            // set player to nil and start seeking func
            seekingTimer = nil
            SeekPlayerTo(newValue)
        })
    }
    
    func SeekPlayerTo(_ offset: TimeInterval) {
        // newTime as var so i can change it
        var newTime = offset
        seekingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            print("Set playeback \(offset)")
            if newTime > player?.duration ?? 0 { newTime = player!.duration}
            player?.currentTime = newTime
            seekingTimer?.invalidate()
            PlayerStatus.playerIsSeeking = false

        }
        
    }
    
    
    func handleProgressTimer() {
        let playingStatus = player?.isPlaying
        if playingStatus ?? false {
            let progress = Double(player!.currentTime)
            print("progress --- ", progress)
        }
    }
}


