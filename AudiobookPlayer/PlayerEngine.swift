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
var ended = false
var playSpeed: Float = 1.0

struct AudioPlayer {
    @ObservedObject var PlayerStatus: AudioPlayerStatus
    let BookFinished = Notification.Name("BookFinished")
    // Create observers for the notifications from the serializer.
    let notificationCenter = NotificationCenter.default
    let delegate = AVdelegate()

    
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
            // this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: playNow!)
            player?.delegate = delegate
            
        } catch let error {
            print("Player Error", error.localizedDescription)
        }
        Play()
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                     successfully flag: Bool) {
        print("Book finished")
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


class AVdelegate : NSObject, AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name("ended"), object: nil)
        print("Book has finished")
        
    }
}
