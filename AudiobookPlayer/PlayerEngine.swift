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

enum PlayingStatus {
    case stopped
    case playing
    case empty
}


class AudioPlayerStatus: ObservableObject {
    @Published var status = PlayingStatus.empty
    @Published var speaker = ""
    @Published var bookname : String?
    @Published var playbackTime = "00:00:00"
    @Published var bookPlaybackWidth = CGFloat(0)
    @Published var playerIsSeeking = false
    @Published var currentBookLenght : Double?
    @Published var currentlyPlayingIndex : Int?
    @Published var currentlyPlayingID : ObjectIdentifier?
    @Published var currentPlaylist : Array<Book>?
    
    private var audioSession : AVAudioSession
    
    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        timeUpdate()
        setupAudioSession()
        setupRemoteTransportControls()
    }
    
    func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
        } catch {
            print("Failed to set audio session route sharing policy: \(error)")
        }
    }
    
    
    // Receive URLdata to play -> initiate play
    func PlayManager(play: URL) {
        
        do {
            
            // Start Playing
            player = try AVAudioPlayer(contentsOf: play)
            
            setupMeta()
            // Setting Book width
            bookPlaybackWidth = player!.duration
            
            // Delegate to listen when book finishes
            player?.delegate = delegate
            
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("Finished"), object: nil, queue: .main)  {_ in
                if bookhasfinished {
                    print("Notification: Requesting next book")
                    self.NextBook()
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
        let bookmarkData = currentPlaylist![nextBookIndex].urldata!
        let URL = restoreURL(bookmarkData: bookmarkData)
        // Assigning newBookID and Name
        let nextBookID = currentPlaylist![nextBookIndex].id
        let nextBookName = currentPlaylist![nextBookIndex].name
        print("Playlist set next book to play at: \(nextBookIndex)")
        
        // updating data for nextbook in observable object
        currentlyPlayingID = nextBookID
        currentlyPlayingIndex = nextBookIndex
        bookname = nextBookName
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
        let CurrentItemID = currentlyPlayingID
        let CurrentPlaylist = currentPlaylist!
        // Finding item that is currently playing
        let newPlayingIndex = CurrentPlaylist.firstIndex(where: { $0.id == CurrentItemID} )!
        currentlyPlayingIndex = newPlayingIndex
        return newPlayingIndex
    }
    
    // Checking if new book exists
    func skipToCurrentItem(offsetBy offset: Int) {
        print("\(currentPlaylist!.count) books in current playlist")
        let NextBookIndex = CurrentPlayingIndex() + offset
        if  (NextBookIndex <= currentPlaylist!.count-1) && (NextBookIndex >= 0) {
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
    
    func Play() {
        print("Play requested")
        player?.prepareToPlay()
        player?.play()
        try? audioSession.setActive(true)
        status = PlayingStatus.playing
        setupInterruption()
    }
    
    func Stop() {
        print("Stop requested")
        player?.stop()
        try? audioSession.setActive(false)
        status = PlayingStatus.stopped
    }
    
    func TogglePlayPause() {
        if status == .playing {
            Stop()
        }
        else {
            Play()
        }
    }
    
    
    func timeUpdate() {
        print("time update func")
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            if self.status == .playing && !self.playerIsSeeking  {
                let seconds = player?.currentTime
                self.playbackTime = formatTimeFor(seconds: seconds ?? 0)
            }
        }
    }
    
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add a handler for the play command.
        commandCenter.playCommand.addTarget { _ in // check out player
            if self.status != .playing {
                self.Play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { _ in
            if self.status == .playing {
                self.Stop()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for next Command
        commandCenter.nextTrackCommand.addTarget { _ in
            self.NextBook()
            return .success
        }
        
        // Add handler for previous Command
        commandCenter.previousTrackCommand.addTarget { _ in
            self.PreviousBook()
            return .success
        }
        noRemoteController = false
    }
    
    // meta for remote controller
    func setupMeta() {
        
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
        nowPlayingInfo[MPMediaItemPropertyTitle] = bookname
        
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
    
    
    func setupInterruption() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: audioSession)
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
            Stop()
        case .ended:
            print("audio continued")
            Play()
            
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // An interruption ended. Resume playback.
                print("interruption ended")
                
                
            } else {
                // An interruption ended. Don't resume playback.
                
            }
            
        default: ()
        }
    }
    
}





class Notifications : NSObject, AVAudioPlayerDelegate {
    // Get the default notification center instance.
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Delegate: Book Finished")
        bookhasfinished = true
        NotificationCenter.default.post(name: NSNotification.Name("Finished"), object: nil)
    }
}
