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


struct PlayerUI: View {
    
    let iconplay = "play.fill"
    let iconstop = "pause.fill"
    @ObservedObject var PlayerStatus: AudioPlayerStatus
    @State var time : CGFloat = 0 // current player progress
    @State var bookname : String = "" // book playing
    @State var speaker : String = "" // Speaker connected
    
    
    // Observe various notifications.
    let notificationCenter = NotificationCenter.default
    
    var body: some View {

        // The sample audio player.
        let audioplayer = AudioPlayer(PlayerStatus: PlayerStatus)
        
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Text(PlayerStatus.speaker)
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
            .onAppear {
                let audioSession = AVAudioSession.sharedInstance().currentRoute
                for output in audioSession.outputs {
                    PlayerStatus.speaker = output.portName
                }
            }
            
            HStack {
                Button {
                    audioplayer.PreviousBook()
                }
            label: {
                Image(systemName:  "backward.fill")
                    .resizable()
                    .frame(width: 38, height: 24, alignment: .center)
                    .foregroundColor(.white)
            }
                Spacer()
                Button {
                    audioplayer.TogglePlayPause()
                }
            label: {
                Image(systemName: PlayerStatus.playing ? iconstop : iconplay)
                    .font(.system(size: 42.0))
                    .frame(width: 32, height: 44, alignment: .center)
                    .foregroundColor(.white)
            }
                Spacer()
                Button {
                    audioplayer.NextBook()
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
   
    
    
    func playerUIcontrol() {
        switch player?.isPlaying {
        case true:
            player?.stop()
//            PlayerStatus.playing = false
        case false:
            player?.play()
//            PlayerStatus.playing = true
        default:
            let _ = print("Nothing")
        }
        if ended {
            player?.currentTime = 0
            time = 0
            ended = false
        }
//                if(PlayerStatus.playing) {
//            //        Refactor progressbar
//                DispatchQueue.global(qos: .background).async {
//                    while true {
//                        let screenWidth = UIScreen.main.bounds.width - 24
//                        let currentTime = player?.currentTime
//                        let duration = player?.duration
//                        let labelPosition = CGFloat(currentTime! / duration!) * screenWidth
//                        self.time = labelPosition
//                    }
//                }
//            }
    }
    
}
