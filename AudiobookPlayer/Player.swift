//
//  Player.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 1/19/22.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation


var player: AVAudioPlayer?

func playSound() {
    guard let path = Bundle.main.path(forResource: "audio", ofType:"m4a") else {
        return }
    let url = URL(fileURLWithPath: path)

    do {
        player = try AVAudioPlayer(contentsOf: url)
    } catch let error {
        print(error.localizedDescription)
    }
}


struct Player: View {
    
    @State var time : CGFloat = 0
    let iconplay = "play.fill"
    let iconstop = "pause.fill"
    @State var playericon = "play.fill"
    
    var body: some View {
        
        VStack {
            HStack {
            VStack(alignment: .leading){
                Text("Yaosamo Airpods")
                    .foregroundColor(Color(red: 0.93, green: 0.59, blue: 0.28))
                    .MainFont(12)
                Text("2010.03.10 Mazda")
                    .MainFont(24)
                    .foregroundColor(.white)
                    .padding([.top, .bottom], 1)
                Text("4:37:22")
                    .MainFont(12)
                    .foregroundColor(.white)
            }
            .padding(.leading, 32)
                Spacer()
            }
            
            
            ZStack {
            Capsule()
                .fill(Color.white).frame(height: 8)
                .padding(8)
            
            Capsule() // progress
                    .fill(Color.white).frame(width: time, height: 8)
                .padding(8)
            }
            .padding([.top, .bottom], 40)
            .onAppear(perform: playSound)
            
            HStack {
                Image(systemName: "backward.fill")
                        .resizable()
                        .frame(width: 38, height: 24, alignment: .center)
                        .foregroundColor(.white)
        
            Spacer()
                               
                Button {
                    let playing = Listening()
                    switch playing {
                    case true:
                        player?.stop()
                        playericon = iconplay
                    case false:
                        player?.play()
                        playericon = iconstop
                    }
                }
                
            label: {
                    Image(systemName: playericon)
                    .font(.system(size: 42.0))
                    .frame(width: 32, height: 44, alignment: .center)
                    .foregroundColor(.white)
                }
                
                Spacer()
                Image(systemName: "forward.fill")
                        .resizable()
                        .frame(width: 38, height: 24, alignment: .center)
                        .foregroundColor(.white)
            }
            .padding([.trailing, .leading], 72)
        }
        
        .frame(height: 330)
        .background(.black)
    }
}

func Listening() -> Bool {
    let playing = player?.isPlaying
    return playing ?? false
}


struct Player_Previews: PreviewProvider {
    static var previews: some View {
        Player()
            .previewLayout(.sizeThatFits)
    }
}
