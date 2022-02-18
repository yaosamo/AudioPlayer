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
    @State var time : String = "00:00:00" // current player progress
    @State var bookname : String = "" // book playing
    @State var speaker : String = "" // Speaker connected
    
    
    var body: some View {
        
        // The sample audio player.
        let audioplayer = AudioPlayer(PlayerStatus: PlayerStatus)
        let bookname = player?.url?.deletingPathExtension().lastPathComponent
        
        VStack {
            HStack {
                VStack(alignment: .leading){
                    Text(PlayerStatus.speaker)
                        .foregroundColor(Color(red: 0.93, green: 0.59, blue: 0.28))
                        .MainFont(12)
                    Text("\(bookname ?? "Nothing to play")")
                        .MainFont(24)
                        .foregroundColor(.white)
                        .padding([.top, .bottom], 1)
                    Text("\(time)")
                        .MainFont(12)
                        .foregroundColor(.white)
                }
                .padding(.leading, 32)
                .onAppear {
                    timeUpdate()
                }
                Spacer()
            }
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white).frame(height: 8)
                    .padding(8)
                Capsule() // progress
                    .fill(Color.red).frame(width: 40, height: 8)
                    .padding(8)
                    .gesture(DragGesture()
                                .onChanged({ (value) in
                        
                        
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
    
    func timeUpdate() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            if PlayerStatus.playing {
                let seconds = player?.currentTime
                time = formatTimeFor(seconds: seconds ?? 0)
            }
        }
    }
    
    func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "0\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        let time = "\(hoursString):\(minutesString):\(secondsString)"
        return time
    }
}
