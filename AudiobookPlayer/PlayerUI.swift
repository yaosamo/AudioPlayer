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


let whiteColor = Color(red: 0.91, green: 0.91, blue: 0.91)


func colorize (hex: Int, alpha: Double = 1.0) -> UIColor {
    let red = Double((hex & 0xFF0000) >> 16) / 255.0
    let green = Double((hex & 0xFF00) >> 8) / 255.0
    let blue = Double((hex & 0xFF)) / 255.0
    let color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
    return color
}


struct PlayerUI: View {
    @EnvironmentObject private var playerEngine: AudioPlayerStatus

    
    let iconplay = "play.fill"
    let iconstop = "pause.fill"
    @State var bookname : String = "" // book playing
    @State var speaker : String = "" // Speaker connected
    
    var body: some View {
        
        // The sample audio player.
        let bookname = playerEngine.bookname
        let playbackTime = playerEngine.playbackTime
        
        VStack(alignment: .leading) {
            
            // Book Name
            VStack(alignment: .leading){
                Text(playerEngine.speaker)
                    .foregroundColor(Color(red: 0.93, green: 0.59, blue: 0.28))
                    .MainFont(12)
                //Refactor animation
                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: true)) {
                    Text("\(bookname ?? "Select something to play")")
                        .MainFont(24)
                        .frame(height: 40, alignment: .leading)
                        .foregroundColor(.white)
                        .padding([.top, .bottom], 1)
                }
                // Book Duration
                Text("\(playbackTime)")
                    .MainFont(12)
                    .foregroundColor(.white)
            }
            .padding(.leading, 24)
//            .onAppear {
//                timeUpdate()
//            }
            // Seeking
            SeekView().environmentObject(playerEngine)
            
            // Audio device name
                .onAppear {
                    let audioSession = AVAudioSession.sharedInstance().currentRoute
                    for output in audioSession.outputs {
                        playerEngine.speaker = output.portName
                    }
                }
            
            HStack {
                Button {
                    playerEngine.PreviousBook()
                }
            label: {
                Image(systemName:  "backward.fill")
                    .resizable()
                    .frame(width: 38, height: 24, alignment: .center)
                    .foregroundColor(.white)
            }
                Spacer()
                Button {
                    playerEngine.TogglePlayPause()
                }
            label: {
                Image(systemName: playerEngine.status == .playing ? iconstop : iconplay)
                    .font(.system(size: 42.0))
                    .frame(width: 32, height: 44, alignment: .center)
                    .foregroundColor(.white)
            }
                Spacer()
                Button {
                    playerEngine.NextBook()
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
