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
//var player2: AVPlayer?
var nextBook = 0
//var del = AVdelegate()
var ended = false
var playSpeed: Float = 1.0

struct AudioPlayer {
    @ObservedObject var PlayerStatus: AudioPlayerStatus
    
    struct playlist2 {
        // Items in the playlist.
        var items: [Books] = []
        // The current item index, or nil if the player is in a stopped state.
        var currentIndex: Int?
    }
    
    func Playlist(books: Array<Book>, PlayNow: ObjectIdentifier) {
        print("Playlist in")
        let CurrentItem = books.firstIndex(where: { $0.id == PlayNow} )!
//        let CurrentItem = books.map { $0.name.a}
        PlayManager(bookmarkData: books[CurrentItem].urldata!)
        print("------items--", playlist2().items)
    }
    
    func SeekToCurrentItem() {
        print("check if item # exists")
        print("Switch playlist item")
    }
    
    func PlayManager(bookmarkData: Data) {
//      Restore security scoped bookmark
        var bookmarkDataIsStale = false
        let playNow = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale)
        print("Please put \(playNow!.lastPathComponent) on")

        do {
            player = try AVAudioPlayer(contentsOf: playNow!)
        } catch let error {
            print("Player Error", error.localizedDescription)
        }
        Play()
    }
    
    func PreviousBook() {
        print("Please play previous book")
    }
    
    func NextBook() {
        print("Please play next book")
    }
    
    
    func TogglePlayPause() {
        if IsPlaying() {
            Stop()
        }
        else {
            Play()
        }
    }
    
    func Play() {
        print("Play requested")
        player?.prepareToPlay()
        player?.play()
        if IsPlaying() {
            PlayerStatus.playing = true
        }
        else {
            print("Hey, nothing to play")   
        }
    }
    
    func Stop() {
        print("Stop requested")
        player?.stop()
        PlayerStatus.playing = false
    }
    
    func IsPlaying() -> Bool {
        let PlayerPlaying = player?.isPlaying
        return PlayerPlaying ?? false
    }
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
//
//class AVdelegate : NSObject,AVAudioPlayerDelegate{
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        NotificationCenter.default.post(name: NSNotification.Name("ended"), object: nil)
//        player.stop()
//    }
//}
