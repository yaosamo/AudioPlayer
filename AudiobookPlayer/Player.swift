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

struct Player: View {
    let iconplay = "play.fill"
    let iconstop = "pause.fill"
    @State var time : CGFloat = 0
    @State var playing = false
    @State var songs = ["song1","song2","song3"]
    @State var currentSong = 1
    
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
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white).frame(height: 8)
                    .padding(8)
                Capsule() // progress
                    .fill(Color.red).frame(width: time, height: 8)
                    .padding(8)
            }
            .padding([.top, .bottom], 40)
            .onAppear(perform: playSound)
            
            HStack {
                Button {
                    if currentSong > 0 {
                        currentSong -= 1}
                    playSound()
                    player?.play()
                    self.playing = true
                    let _ = print("playing #:",currentSong)
                }
            label: {Image(systemName:  "backward.fill")
                    .resizable()
                    .frame(width: 38, height: 24, alignment: .center)
                .foregroundColor(.white)
            }
                Spacer()
                Button {
                    let playing = Listening()
                    switch playing {
                    case true:
                        player?.stop()
                        self.playing = false
                    case false:
                        player?.play()
                        self.playing = true
                        let _ = print("playing #:",currentSong)

                    }
                    // progressbar
                    DispatchQueue.global(qos: .background).async {
                        while true {
                        let screenWidth = UIScreen.main.bounds.width - 24
                        let currentTime = player?.currentTime
                        let duration = player?.duration
                        let labelPosition = CGFloat(currentTime! / duration!) * screenWidth
                        self.time = labelPosition
                        }
                    }
                }
            label: {
                Image(systemName: self.playing ? iconstop : iconplay)
                    .font(.system(size: 42.0))
                    .frame(width: 32, height: 44, alignment: .center)
                    .foregroundColor(.white)
            }
                Spacer()
                Button {
                    if currentSong < songs.count-1 {
                        currentSong += 1}
                    playSound()
                    player?.play()
                    self.playing = true
                   
                    let _ = print("playing #:",currentSong)
                }
            label: {Image(systemName: "forward.fill")
                    .resizable()
                    .frame(width: 38, height: 24, alignment: .center)
                    .foregroundColor(.white)
            }
            } //hstack
            .padding([.trailing, .leading], 72)
        } //vstack
        .frame(height: 330)
        .background(.black)
    }
    func playSound() {
        guard let path = Bundle.main.path(forResource: songs[currentSong], ofType:"m4a") else {
            return }
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
        } catch let error {
            print(error.localizedDescription)
        }
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
