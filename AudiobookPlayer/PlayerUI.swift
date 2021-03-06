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

let darkProgressBar = Color(red: 0.17, green: 0.17, blue: 0.18)
let whiteColor = Color(red: 0.91, green: 0.91, blue: 0.91)
let darkColor = Color(red: 0.07, green: 0.07, blue: 0.08)   
let inactiveColor = Color(red: 0.24, green: 0.25, blue: 0.28)
let borderColor = Color(red: 0.08, green: 0.09, blue: 0.10)
let lightDark = Color(red: 0.32, green: 0.33, blue: 0.36)

// playlist colors
var biege = Color(red: 0.88, green: 0.83, blue: 0.68)
let lightblue = Color(red: 0.62, green: 0.78, blue: 0.78)
let purple = Color(red: 0.40, green: 0.45, blue: 0.94)
let brown = Color(red: 0.69, green: 0.33, blue: 0.22)
let pink = Color(red: 0.75, green: 0.51, blue: 0.82)
let gray = Color(red: 0.68, green: 0.68, blue: 0.68)
let green = Color(red: 0.34, green: 0.59, blue: 0.49)

var colorslist = [biege, lightblue, purple, brown, pink, gray, green]



struct PlayerUI: View {
    @EnvironmentObject private var playerEngine: AudioPlayerStatus
    
    
    let iconplay = "play.fill"
    let iconstop = "pause.fill"
    
    var body: some View {
        
        // The sample audio player.
        let bookname = playerEngine.bookname
        let playbackTime = playerEngine.playbackTime

        VStack(alignment: .leading) {
            
            // Book Name
            VStack(alignment: .leading) {
                
                Text(playerEngine.speaker)
                    .foregroundColor(Color(red: 0.93, green: 0.59, blue: 0.28))
                    .MainFont(Size: 12, Weight: .medium)
                    .animation(.default, value: 8)
                    .padding(.bottom, -4)
               
                //Refactor animation
                withAnimation(Animation.linear(duration: 10).repeatForever(autoreverses: true)) {
                    Text("\(bookname ?? "Select something to play")")
                        .MainFont(Size: 24, Weight: .medium)
                        .frame(height: 40, alignment: .leading)
                        .foregroundColor(playerEngine.status == .empty ? inactiveColor : whiteColor)
                        .padding([.top, .bottom], -4)
                }
                // Book Duration
                Text("\(playbackTime)")
                    .MainFont(Size: 12, Weight: .medium)
                    .foregroundColor(playerEngine.status == .empty ? inactiveColor : whiteColor)
            } // vStack meta block
            .padding([.leading, .trailing], 24)
            .padding(.top, 24)
            
            SeekView()
                .environmentObject(playerEngine)
                .padding(.top, -8)
            
            HStack {
                Button {
                    playerEngine.PreviousBook()
                }
            label: {
                Image(systemName:  "backward.fill")
                    .resizable()
                    .frame(width: 38, height: 24, alignment: .center)
                    .foregroundColor(playerEngine.status == .empty ? inactiveColor : whiteColor)
            }
                Spacer()
                Button {
                    playerEngine.TogglePlayPause()
                }
            label: {
                Image(systemName: playerEngine.status == .playing ? iconstop : iconplay)
                    .font(.system(size: 42.0))
                    .frame(width: 32, height: 44, alignment: .center)
                    .foregroundColor(playerEngine.status == .empty ? inactiveColor : whiteColor)
            }
                Spacer()
                Button {
                    playerEngine.NextBook()
                }
            label: {
                Image(systemName: "forward.fill")
                    .resizable()
                    .frame(width: 38, height: 24, alignment: .center)
                    .foregroundColor(playerEngine.status == .empty ? inactiveColor : whiteColor)
            }
            } //buttons
            .padding([.trailing, .leading], 72)
            .padding(.bottom, 24)
        } //vstack
        .background(darkColor)
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
