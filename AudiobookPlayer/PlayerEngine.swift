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
import MediaPlayer

var player: AVAudioPlayer?
let delegate = Notifications()
var bookhasfinished = false
var noRemoteController = true


class Notifications : NSObject, AVAudioPlayerDelegate {
    // Get the default notification center instance.
    let nc = NotificationCenter.default

    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Delegate: Book Finished")
        bookhasfinished = true
        nc.post(name: NSNotification.Name("Finished"), object: nil)
    }
    
    
    func setupNotifications() {
        nc.addObserver(self,
                       selector: #selector(handleInterruption),
                       name: AVAudioSession.interruptionNotification,
                       object: AVAudioSession.sharedInstance())
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        // Switch over the interruption type.
        switch type {

        case .began:
            print("audio interrupted")

        case .ended:
            print("audio continue")

            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // An interruption ended. Resume playback.
            } else {
                // An interruption ended. Don't resume playback.
            }

        default: ()
        }
    }
    
}


struct AudioPlayer {
    @ObservedObject var PlayerStatus: AudioPlayerStatus
    
    // Receive URLdata to play -> initiate play
    func PlayManager(play: URL) {
        
        do {
            // this codes for making this app ready to takeover the device audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Start Playing
            player = try AVAudioPlayer(contentsOf: play)
            
            // Setting Book width
            PlayerStatus.bookPlaybackWidth = player!.duration
            // set remote controller and meta data for it + updating observabl object
            setupNowPlaying()
            
            if noRemoteController {
                setupRemoteTransportControls()
            }
            
            // Delegate to listen when book finishes
            player?.delegate = delegate
            // Setting up
            delegate.setupNotifications()
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Finished"), object: nil, queue: .main)  {_ in
                if bookhasfinished {
                    print("Notification: Requesting next book")
                    NextBook()
                    bookhasfinished = false
                }
            }
            Play()
            
        } catch let error {
            print("Player Error", error.localizedDescription)
        }
        
    }
    
    
    // Get current book URL Data for Play Manager
    func Playlist(at nextBookIndex: Int) {
        // Getting current item bookmarkData
        let bookmarkData = PlayerStatus.currentPlaylist![nextBookIndex].urldata!
        let URL = restoreURL(bookmarkData: bookmarkData)
        // Assigning newBookID and Name
        let nextBookID = PlayerStatus.currentPlaylist![nextBookIndex].id
        let nextBookName = PlayerStatus.currentPlaylist![nextBookIndex].name
        print("Playlist set next book to play at: \(nextBookIndex)")
        
        // updating data for nextbook in observable object
        PlayerStatus.currentlyPlayingID = nextBookID
        PlayerStatus.currentlyPlayingIndex = nextBookIndex
        PlayerStatus.bookname = nextBookName
        PlayManager(play: URL)
    }
    
    func restoreURL(bookmarkData: Data) -> URL {
        // Restore security scoped bookmark
        var bookmarkDataIsStale = false
        let URL = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale)
        print("Please put \(URL!.lastPathComponent) on")
        return URL!
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
        else { print("Requested book doesn't exist at", NextBookIndex) }
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
        player?.stop()
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
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add a handler for the play command.
        commandCenter.playCommand.addTarget { _ in // check out player
            if !PlayerStatus.playing {
                Play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { _ in
            if PlayerStatus.playing {
                Stop()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for next Command
        commandCenter.nextTrackCommand.addTarget { _ in
            NextBook()
            return .success
        }
        
        // Add handler for previous Command
        commandCenter.previousTrackCommand.addTarget { _ in
            PreviousBook()
            return .success
        }
        noRemoteController = false
    }
    
    // meta for remote controller
    func setupNowPlaying() {
        
        var artwork = Optional(UIImage())
        
        let asset = AVAsset(url: player!.url!)
        // getting artwork
        let artworkItems = AVMetadataItem.metadataItems(from: asset.metadata,
                                                        filteredByIdentifier: .commonIdentifierArtwork)
        if let artworkItem = artworkItems.first {
            // Coerce the value to a Data value using its dataValue property
            if let imageData = artworkItem.dataValue {
                artwork = UIImage(data: imageData)
            } else {
                // No image data was found.
            }
        }
        
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = PlayerStatus.bookname
        
        if let image = artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
