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
    let center = UIScreen.main.bounds.width / 2
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>
    @State private var progress : Double = Double()
    let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    init() {
        let detector = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = detector
            .debounce(for: .seconds(0), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.detector = detector
   
    }
    
    
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
                        .frame(width: player?.duration ?? 0, height: 48)
//                        .offset(x: -progress)
                        // Caret - playback position
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("scroll")).origin.x)
                        })
                        // added center to compensate padding
                        .onPreferenceChange(ViewOffsetKey.self) { detector.send($0+center) }
                        .onReceive(progressTimer) { _ in handleProgressTimer()}
                }
            })
            // Trailing padding for whole lazy stack so caret and playback bounces off
            .padding([.trailing], center)
        }
        .coordinateSpace(name: "scroll")
        .onReceive(publisher) {
          
            if seekingTimer != nil {seekingTimer!.invalidate()
                print("invalidate!")
            }
                seekingTimer = nil
                print("start seeking!")
                SeekPlayerTo($0)

        }
        
    }
    
    func SeekPlayerTo(_ offset: TimeInterval) {
            var newTime = offset
            seekingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            print("Set playeback \(offset)")
            if newTime > player!.duration { newTime = player!.duration}
            player?.currentTime = newTime
            seekingTimer?.invalidate()
            }
        }
    
    func handleProgressTimer() {
        let playingStatus = player?.isPlaying
        if playingStatus ?? false {
            progress = Double(player!.currentTime)
//            print("progress --- ", progress)
        }
    }
}


