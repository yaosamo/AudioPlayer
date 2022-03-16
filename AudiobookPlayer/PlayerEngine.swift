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
    @Published var speaker = "iPhone"
    @Published var bookname : String?
    @Published var playbackTime = "00:00:00"
    @Published var bookPlaybackWidth = CGFloat(0)
    @Published var playerIsSeeking = false
    
    @Published var currentBookIndex : Int?
    @Published var currentPlaylistIndex : Int?
    
    @Published var currentBookID : ObjectIdentifier?
    @Published var currentPlaylistID : ObjectIdentifier?

    @Published var currentPlaylist : Array<Book>?
    @Published var allPlaylists : FetchedResults<Playlist>?
    
    @Published var proxy : ScrollViewProxy?
        
    private var audioSession : AVAudioSession
    
    @AppStorage("playlistID") var restoreplaylistIndex: Int?
    @AppStorage("bookID") var restorebookIndex: Int?
    @AppStorage("playbackTime") var restorePlayback: String?

    
    init() {
        audioSession = AVAudioSession.sharedInstance()
        timeUpdate()
        setupAudioSession()
        setupRemoteTransportControls()
        setupNotifications()
        setOutput()
    }
    
    func abortPlay() {
        player = nil
        status = PlayingStatus.empty
        bookname = "Select something to play"
        playbackTime = "00:00:00"
        bookPlaybackWidth = CGFloat(0)
        currentBookIndex = nil
        currentBookID = nil
        currentPlaylist = nil
        
        restoreplaylistIndex = nil
        restorebookIndex = nil
        restorePlayback = nil
    }
    
    func SavePlay() {
        restoreplaylistIndex = CurrentPlaylistIndex()
        restorebookIndex = CurrentBookIndex()
    }
    
    func restorePlay() {
        print("restoring play")
        currentPlaylist = restorePlaylist()
        currentPlaylistID = allPlaylists![restoreplaylistIndex!].id
        let book = currentPlaylist![restorebookIndex!]
        let url = restoreURL(bookmarkData: book.urldata!)
        currentBookID = book.id
        bookname = book.name
        playbackTime = restorePlayback ?? "00:00:00"
        PlayManager(play: url)
        Stop()
    }
    
    func restorePlaylist() -> Array<Book> {
        let Playlist = allPlaylists![restoreplaylistIndex!].book!.sortedArray(using: [booksorting]) as! [Book]
        return Playlist
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
            status = PlayingStatus.playing
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
        currentBookID = nextBookID
        currentBookIndex = nextBookIndex
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
    func CurrentBookIndex() -> Int {
        // Finding item that is currently playing
            let newBookIndex = currentPlaylist!.firstIndex(where: { $0.id == currentBookID} )!
        currentBookIndex = newBookIndex
            return newBookIndex
    }
    
    func CurrentPlaylistIndex() -> Int {
        let newPlaylistIndex = allPlaylists!.firstIndex(where: { $0.id == currentPlaylistID} )!
        currentPlaylistIndex = newPlaylistIndex
        return newPlaylistIndex
    }
    
    
    // Checking if new book exists
    func skipToCurrentItem(offsetBy offset: Int) {
        print("\(currentPlaylist!.count) books in current playlist")
        let NextBookIndex = CurrentBookIndex() + offset
        if  (NextBookIndex <= currentPlaylist!.count-1) && (NextBookIndex >= 0) {
            print("Requested book exists at:", NextBookIndex)
            Playlist(at: NextBookIndex)
        }
        else { print("Requested book doesn't exist at", NextBookIndex) }
    }
    
    
    func PreviousBook() {
        if status != .empty {
            print("Please play previous book")
            skipToCurrentItem(offsetBy: -1)
        }
        SavePlay()
    }
    
    func NextBook() {
        if status != .empty {
            print("Please play next book")
            skipToCurrentItem(offsetBy: +1)
        }
        SavePlay()
    }
    
    func Play() {
        print("Play requested")
        player?.prepareToPlay()
        player?.play()
        try? audioSession.setActive(true)
        if status != .empty {
            status = PlayingStatus.playing
        }
    }
    
    func Stop() {
        print("Stop requested")
        player?.stop()
        try? audioSession.setActive(false)
        if status != .empty {
            status = PlayingStatus.stopped
        }
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
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] (_) in
            if status == .playing && !playerIsSeeking  {
                let seconds = player?.currentTime
                playbackTime = formatTimeFor(seconds: seconds ?? 0)
                restorePlayback = playbackTime
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
    
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: audioSession)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
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
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // An interruption ended. Resume playback.
                print("interruption ended")
                Play()
            }
        default: ()
        }
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                  return
              }
        
        // Switch over the route change reason.
        switch reason {
            
        case .newDeviceAvailable: // New device found.
            setOutput()
            
        default: setOutput()
            
        }
    }
    
    func setOutput() {
        if audioSession.currentRoute.outputs[0].portName == "Speaker" {
            speaker = "iPhone"
            Stop()
        } else {
            speaker = audioSession.currentRoute.outputs[0].portName
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
