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
    @EnvironmentObject private var playerEngine: AudioPlayerStatus
    
    @State private var seekingTimer : Timer?
    @State private var offset = CGFloat.zero
    @State private var dragInitiated = false
    @State private var progress = 0.0
    @State private var validView = true
    @Namespace var currentProgress
    @Namespace var startPoint
    let center = UIScreen.main.bounds.width / 2
    
    var caret: some View {
        Rectangle()
            .fill(playerEngine.status == .empty ? inactiveColor : whiteColor)
            .frame(width: 2, height: 48, alignment: .trailing)
        //compensate 2 for caret
            .padding([.leading], center-1)
    }
   

    var body: some View {
       
        ScrollViewReader { proxy in
            
            if validView {
            ScrollView(.horizontal) {
                LazyHStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders], content: {
                    Section(header: caret) {
                        ZStack(alignment: .leading) {
                            // Book's Scroll
                                
                            Rectangle()
                                .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                                .frame(width: playerEngine.bookPlaybackWidth, height: 40)
                            // Caret - playback position
                                .background(GeometryReader {
                                    Color.clear.preference(key: ViewOffsetKey.self,
                                                           value: -$0.frame(in: .named("scroll")).origin.x)
                                })
                                .onPreferenceChange(ViewOffsetKey.self) {
                                    // Updating offset and applying center to get caret offset
                                    offset = $0+center
                                }
                            
                            // starting trigger
                            Rectangle()
                                .frame(width:0)
                                .id(startPoint)
                            
                            // progressing bar
                            ZStack(alignment: .trailing) {
                            Rectangle()
                                .fill(Color(red: 0.30, green: 0.30, blue: 0.30))
                                .frame(width: (playerEngine.restorePlayback ?? progress), height: 40)
                            
                            // currentProgress trigger
                            Rectangle()
                                .frame(width: 0)
                                .id(currentProgress)
                            }
                            
                        } // Zstack
                        .onChange(of: progress) { _ in
                            progressUpdate(proxy: proxy)
                        }
                        
                    }
                    // resets caret position to Start when new book started
                    .onChange(of: playerEngine.bookPlaybackWidth) { _ in
                        proxy.scrollTo(startPoint, anchor: .trailing)
                    }
                })
                // Trailing padding for whole lazy stack so caret and playback bounces off
                .padding([.trailing], center)
                
            }
            .frame(height: 96)
            .coordinateSpace(name: "scroll")
            // check if drag happened
            .gesture(DragGesture()
                .onChanged({ _ in
                    dragInitiated = true
                }))
            .onChange(of: offset, perform: { newValue in
                // allow offset to process if drag happened
                if dragInitiated {
                    playerEngine.playerIsSeeking = true
                    // check offset and if it's less than 0 set playback to 0.
                    if offset > 0 && playerEngine.status != .empty {
                        playerEngine.playbackTime = formatTimeFor(seconds: offset)}
                    else { playerEngine.playbackTime = "00:00:00"}
                    
                    // if player exist delete it
                    if seekingTimer != nil {seekingTimer!.invalidate()
                    }
                    // set player to nil and start seeking func
                    seekingTimer = nil
                    SeekPlayerTo(newValue)
                }
            })
            }
        }
        
    }
    
    
    private func progressUpdate(proxy : ScrollViewProxy) {

            if playerEngine.status == .playing && !playerEngine.playerIsSeeking  {
                withAnimation {
                    progress = player?.currentTime ?? 0
                    proxy.scrollTo(currentProgress)
                    print("scroll")
                }
            }
        
    }
    
    func SeekPlayerTo(_ newTime: TimeInterval) {
        var time = newTime
        // newTime as var so i can change it
        seekingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if time >= player?.duration ?? 0 { playerEngine.NextBook() }
            if time < 0 { time = 0}
            player?.currentTime = time
            progress = time
            print("Set playback \(time)")
            seekingTimer?.invalidate()
            playerEngine.playerIsSeeking = false
            dragInitiated = false
        }
    }
}
