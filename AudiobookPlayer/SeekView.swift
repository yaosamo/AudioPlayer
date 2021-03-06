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
    @Namespace var currentProgress
    
    let center = UIScreen.main.bounds.width / 2
    
    var caret: some View {
        Rectangle()
            .fill(playerEngine.status == .empty ? inactiveColor : whiteColor)
            .frame(width: 2, height: 48)
    }
    
    var body: some View {
        
        ScrollViewReader { proxy in
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack(alignment: .leading) {
                        // Book's width
                        Path{ path in
                            path.move(to: CGPoint(x: 0, y: 20))
                            path.addLine(to: CGPoint(x: playerEngine.bookPlaybackWidth, y: 20))
                        }
                        .stroke(style: StrokeStyle( lineWidth: 40, dash: [2]))
                        .foregroundColor(darkProgressBar)
                        .frame(width: playerEngine.bookPlaybackWidth, height: 40)
                        
                        // Caret - offset
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("scroll")).origin.x)
                        })
                        .onPreferenceChange(ViewOffsetKey.self) {
                            // Updating offset and applying center to get caret offset
                            offset = $0+center
                        }
                        
                        // progress
                        Path{ path in
                            path.move(to: CGPoint(x: 0, y: 20))
                            path.addLine(to: CGPoint(x: playerEngine.currentProgress ?? 0, y: 20))
                        }
                        .stroke(style: StrokeStyle( lineWidth: 40, dash: [2]))
                        .foregroundColor(lightDark)
                        .frame(width: playerEngine.currentProgress ?? 0, height: 40)
                        .id(currentProgress)
                    } // zStack
                    .onChange(of: playerEngine.currentProgress) { _ in
                        autoScroll(proxy: proxy)
                    }
                    .padding([.leading, .trailing], center)
                } // scroll view
                .frame(height: 56)
                .padding([.top, .bottom], 12)
                .coordinateSpace(name: "scroll")
                
                // check if drag happened
                .gesture(DragGesture()
                    .onChanged({ _ in
                        dragInitiated = true
                        playerEngine.Stop()
                    }))
                .onChange(of: offset, perform: { newValue in
                    // allow offset to process if drag happened
                    if dragInitiated {
                        playerEngine.playerIsSeeking = true
                        // check offset and if it's less than 0 set playback to 0.
                        if offset > 0 && playerEngine.status != .empty {
                            playerEngine.playbackTime = formatTimeFor(seconds: offset)
                        }
                        else { playerEngine.playbackTime = "00:00:00"}
                        
                        // if player exist delete it
                        if seekingTimer != nil { seekingTimer!.invalidate() }

                        // set player to nil and start seeking func
                        seekingTimer = nil
                        SeekPlayerTo(newValue)
                    }
                })
                caret
            }
        }
    }
    
    
    private func autoScroll(proxy : ScrollViewProxy) {
        if playerEngine.status == .playing && !playerEngine.playerIsSeeking  {
            withAnimation {
                proxy.scrollTo(currentProgress, anchor: .trailing)
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
            seekingTimer?.invalidate()
            playerEngine.playerIsSeeking = false
            dragInitiated = false
            playerEngine.Play()
        }
    }
}
