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
            //compensate 2 for
            .padding([.leading], center-2)
    }
    
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0, pinnedViews: [.sectionHeaders], content: {
                Section(header: caret) {
                    
                    // Book's Scroll
                    Rectangle()
                        .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .frame(width: player?.duration ?? 0 , height: 48)
                        .onReceive(progressTimer) { _ in handleProgressTimer()}
                        .offset(x: -progress)
                        // Caret - playback position
                        .background(GeometryReader {
                            Color.clear.preference(key: ViewOffsetKey.self,
                                                   value: -$0.frame(in: .named("scroll")).origin.x)
                        })
                        // added center to compensate padding
                        .onPreferenceChange(ViewOffsetKey.self) { detector.send($0+center-2) }
                }
            })
            // Trailing padding for whole lazy stack so caret and playback bounces off -2 for width of caret
                .padding([.trailing], center-2)
        }
        .coordinateSpace(name: "scroll")
        .onReceive(publisher) {
            print("\($0)")
        }
    }
    
    func handleProgressTimer() {
        if ((player?.isPlaying) != nil) && true {
            progress = Double(player!.currentTime)
            print("progress --- ", progress)
        }
    }
}

