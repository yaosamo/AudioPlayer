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
    
    // Get current book URL Data for Play Manager
    func Playlist(at NextBookIndex: Int) {
        // Getting current item bookmarkData
        let bookmarkData = PlayerStatus.currentPlaylist![NextBookIndex].urldata!
        let newBookID = PlayerStatus.currentPlaylist![NextBookIndex].id
        print("Playlist set next book to play at: \(NextBookIndex)")
        PlayerStatus.currentlyPlayingID = newBookID
        PlayManager(bookmarkData: bookmarkData)
    }
    
    // Defining index of currently playing book
    func CurrentPlayingIndex() -> Int {
        // Assign new variables
        let CurrentItemID = PlayerStatus.currentlyPlayingID
        let CurrentPlaylist = PlayerStatus.currentPlaylist!
        // Finding item that is currently playing
        let CurrentPlayingIndex = CurrentPlaylist.firstIndex(where: { $0.id == CurrentItemID} )!
        PlayerStatus.currentlyPlayingIndex = CurrentPlayingIndex
        return CurrentPlayingIndex
    }
    
    // Checking if new book exists
    func skipToCurrentItem(offsetBy offset: Int) {
        print("\(PlayerStatus.currentPlaylist!.count) books in current playlist")
        let NextBookIndex = CurrentPlayingIndex() + offset
        if  (NextBookIndex <= PlayerStatus.currentPlaylist!.count-1) && (NextBookIndex >= 0) {
            print("Requested book exists at:", NextBookIndex)
            Playlist(at: NextBookIndex)
        }
        else { print("Requested book doesn't exist", NextBookIndex) }
    }
    
    // Receive URLdata to play -> initiate play
    func PlayManager(bookmarkData: Data) {
        // Restore security scoped bookmark
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
        skipToCurrentItem(offsetBy: -1)
    }
    
    func NextBook() {
        print("Please play next book")
        skipToCurrentItem(offsetBy: +1)
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
