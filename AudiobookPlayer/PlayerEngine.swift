//
//  PlayerEngine.swift
//  AudiobookPlayer
//
//  Created by Yaroslav Samoylov on 2/9/22.
//

import Foundation
import SwiftUI
import CoreData
import AVFoundation

var player: AVAudioPlayer?
var nextBook = 0
var del = AVdelegate()
var ended = false
var playSpeed: Float = 1.0



func Audioplayer(bookmarkData: Data) {
    
    // Restore security scoped bookmark
    var bookmarkDataIsStale = false
    let playNow = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale)
    
    do {
        player = try AVAudioPlayer(contentsOf: playNow!)
    } catch let error {
        print("Player Error", error.localizedDescription)
    }
    player?.prepareToPlay()
    player?.play()
}

func Play() {
    print("Play requested")
}

func IsPlaying() -> Bool {
    let PlayerPlaying = player?.isPlaying
    return PlayerPlaying ?? false
}

//
//func Autoplay(books: Array<Book>) {
//    let playNow = player?.url
//    let finishedBook = books.firstIndex(where: {$0.url == playNow})
//    let _ = print("----- Just finished book #", finishedBook!)
//    let LastBook = books.count-1
//    if (finishedBook! < LastBook) {
//        nextBook += 1
//    }
//    player?.prepareToPlay()
//    let playNext = books[nextBook].url!
//    let _ = print("----- Starting to play book #", nextBook, playNext.lastPathComponent)
//
//    player?.prepareToPlay()
//    ended = false
//
//    //    Audioplayer(playNow: playNext, books: books)
//}

class AVdelegate : NSObject,AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("ended"), object: nil)
        player.stop()
    }
}
