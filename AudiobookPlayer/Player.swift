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
    @State var data : Data = .init(count: 0)
    @State var del = AVdelegate()
    @State var time : CGFloat = 0
    @State var playing = false
    @State var ended = false
    @State var songs = ["song1","song2","song3"]
    @State var currentSong = 0
    
    let heinz : String = "/Users/yaroslavsamoylov/Library/Developer/CoreSimulator/Devices/4E61E03D-8DD0-4288-9612-40F045692795/data/Library/Mobile%20Documents/com~apple~CloudDocs/_Storage/Audio-books/%D0%91%D1%80%D0%B5%D0%BD%D0%B4%D1%8F%D1%82%D0%B8%D0%BD%D0%B0/2008.02.05%20Heinz.mp3"

//    /Users/yaroslavsamoylov/Library/Developer/CoreSimulator/Devices/4E61E03D-8DD0-4288-9612-40F045692795/data/Containers/Bundle/Application/A3CB4A0B-EB8F-4014-A867-88B6881ECD4B/AudiobookPlayer.app/song1.m4a
    
//    /Users/yaroslavsamoylov/Library/Developer/CoreSimulator/Devices/4E61E03D-8DD0-4288-9612-40F045692795/data/Containers/Bundle/Application/A3CB4A0B-EB8F-4014-A867-88B6881ECD4B/AudiobookPlayer.app/song1.m4a
    
    
    var body: some View {
        let playURL : URL = URL(fileURLWithPath: heinz)
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
                    .gesture(DragGesture()
                        .onChanged({ (value) in
                            
                            let x = value.location.x
                            
                            time = x
                            
                        }).onEnded({ (value) in
                            
                            let x = value.location.x
                            
                            let screen = UIScreen.main.bounds.width - 24
                            
                            let percent = x / screen
                            
                            player?.currentTime = Double(percent) * player!.duration
                        }))
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
                    }
                    if ended {
                        player?.currentTime = 0
                        time = 0
                        ended = false
                    }
//                     progressbar
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
                Image(systemName: self.playing && !ended ? iconstop : iconplay)
                    .font(.system(size: 42.0))
                    .frame(width: 32, height: 44, alignment: .center)
                    .foregroundColor(.white)
            }
                Spacer()
                Button {
                    if songs.count-1 != currentSong {
                        currentSong += 1}
                    playSound()
                    player?.play()
                    self.playing = true
                }
            label: {
                Image(systemName: "forward.fill")
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
        let url2 = URL(fileURLWithPath: path)
        let url = URL(string: heinz)
        let _ = print("--------PATH-------",path)
        let _ = print("---------URL------",url)
        
        do {
            player = try AVAudioPlayer(contentsOf: url ?? url2)
            let _ = print("Playsoung func init")
            let _ = print("playing #:", currentSong)

            player?.delegate = del
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ended"), object: nil, queue: .main) { (_) in
                ended = true
                playing = false
                player?.stop()
                let _ = print("Song finished")
                Autoplay()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func Autoplay() {
        if songs.count-1 != currentSong {
            currentSong += 1}
        let _ = print("Starting to play #:", currentSong)
        player?.prepareToPlay()
        ended = false
        
        playSound()
        player?.play()
        playing = true
    }
}

func Listening() -> Bool {
    let playing = player?.isPlaying
    return playing ?? false
}

class AVdelegate : NSObject,AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name("ended"), object: nil)
    }
}


struct Player_Previews: PreviewProvider {
    static var previews: some View {
        Player()
            .previewLayout(.sizeThatFits)
    }
}
