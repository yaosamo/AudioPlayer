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
    
    let detector: CurrentValueSubject<CGFloat, Never>
    let publisher: AnyPublisher<CGFloat, Never>
    
    init() {
           let detector = CurrentValueSubject<CGFloat, Never>(0)
           self.publisher = detector
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.main)
               .dropFirst()
               .eraseToAnyPublisher()
           self.detector = detector
       }
       
    
    var body: some View {
        ScrollView(.horizontal) {
            let center = UIScreen.main.bounds.width / 2

                      // Book's Scroll
                      Rectangle()
                          .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                          .frame(width: player?.duration ?? 0 , height: 48, alignment: .trailing)
                          .padding([.leading, .trailing], center)
                  .background(GeometryReader {
                      Color.clear.preference(key: ViewOffsetKey.self,
                          value: -$0.frame(in: .named("scroll")).origin.x)
                  })
                  .onPreferenceChange(ViewOffsetKey.self) { detector.send($0) }
            
              }.coordinateSpace(name: "scroll")
              .onReceive(publisher) {
                  player?.currentTime = $0
              }
          }
    }
 
