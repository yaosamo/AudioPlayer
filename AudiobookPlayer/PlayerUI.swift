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
    
    let iconplay = "play.fill"
    let iconstop = "pause.fill"
    @ObservedObject var PlayerStatus: AudioPlayerStatus
    @State var time : String = "00:00:00" // current player progress
    @State var bookname : String = "" // book playing
    @State var speaker : String = "" // Speaker connected
    @Namespace var topID
    
    @State private var progress : Double = Double()
    let progressTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        // The sample audio player.
        let audioplayer = AudioPlayer(PlayerStatus: PlayerStatus)
        let bookname = PlayerStatus.bookname
        
        VStack(alignment: .leading) {
            
            VStack(alignment: .leading){
                Text(PlayerStatus.speaker)
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
                
                Text("\(time)")
                    .MainFont(12)
                    .foregroundColor(.white)
            }
            .padding(.leading, 24)
            .onAppear {
                timeUpdate()
            }
            
            
            ZStack{
                let center = UIScreen.main.bounds.width / 2
                ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    
                    Rectangle()
                        .fill(Color(red: 0.17, green: 0.17, blue: 0.18))
                        .frame(width: player?.duration ?? 0 , height: 48, alignment: .trailing)
                        .padding([.leading, .trailing], center)
                        .onReceive(progressTimer) { _ in handleProgressTimer()}
                    //                            .offset(x: 0)
                    //                            .position(x: 2000, y: 50)
                    HStack(spacing: 0) {
                                  ForEach(0..<100) { i in
                                      Rectangle()
                                          .frame(width: 1 ,height: 32)
                                  }
                              }
                    
                }
                    
                }
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 1, height: 56)
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
    //    func getProgress() -> Double { min(1, Double(elapsed) / Double(duration)) }
    
    
    func handleProgressTimer() {
        if PlayerStatus.playing {
            progress = Double(player!.currentTime)
            print("progress --- ", progress)
        }
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
    
    public func scrollViewWillBeginDragging() {
        print("right")
    }
}

struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}
