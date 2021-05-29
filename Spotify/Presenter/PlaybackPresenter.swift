//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 27/05/21.
//
import AVFoundation
import Foundation
import UIKit

// Procotol: PlayerDataSource
protocol PlayerDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}
// Class: PlaybackPresenter
final class PlaybackPresenter{
    // Singleton shared instance
    static let shared = PlaybackPresenter()
    // Private: Hold track
    private var track: AudioTrack?
    // Hold tracks
    private var tracks = [AudioTrack]()
    //Index
    var index = 0
    // Current track
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        }
        else if (self.playerQueue != nil), !tracks.isEmpty {
            return tracks[index]
        }
        return nil
    }
    // create PlayerVC
    var playerVC: PlayerViewController?
    // AVPlayer
    var player: AVPlayer?
    // AVQueuePlayer
    var playerQueue: AVQueuePlayer?
    // Individual Audio Track
    func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ){
        guard let url = URL(string: track.preview_url ?? "") else {
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        // VC: PlayerViewController
        let vc = PlayerViewController()
        vc.title = track.name
        
        vc.dataSource = self
        vc.delegate = self
        
        viewController.present(
            UINavigationController(rootViewController: vc),
            animated: true) { [weak self]  in
                self?.player?.play()
            }
        self.playerVC = vc
    }
    
    // Album
     func startPlayback(
        from viewController: UIViewController,
        tracks: [AudioTrack]
    ){
        self.tracks = tracks
        self.track = nil
        
        self.playerQueue = AVQueuePlayer(items: tracks.compactMap({
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        }))
        self.playerQueue?.volume = 0.5
        self.playerQueue?.play()
        
        // VC: PlayerViewController
        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        vc.title = tracks.first?.name
        viewController.present(
            UINavigationController(rootViewController: vc),
            animated: true,
            completion: nil)
        self.playerVC = vc
    }
}

// Extension: PlaybackPresenter to conform to PlayerViewControllerDelegate
extension PlaybackPresenter: PlayerViewControllerDelegate{
    func didSlideSlider(_ value: Float) {
        player?.volume = value
        print(value)
    }
    
    func didTapPlayPause() {
        if let player = player{
            if player.timeControlStatus == .playing{
                player.pause()
            }
            else if player.timeControlStatus == .paused{
                player.play()
            }
        }
        else if let player = playerQueue{
            if player.timeControlStatus == .playing{
                player.pause()
            }
            else if player.timeControlStatus == .paused{
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty{
            //Not playlist or album
            player?.pause()
        }
        else if let player = playerQueue{
            player.advanceToNextItem()
            index += 1
            print(index)
            playerVC?.refreshUI()
        }
       
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            //Not playlist or album
            player?.pause()
            player?.play()
        }
        else if let firstItem = playerQueue?.items().first{
            playerQueue?.pause()
            playerQueue?.removeAllItems()
            playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
        }
    }
    
    
}

// Extend PlaybackPresenter class to confirm to DataSource
extension PlaybackPresenter: PlayerDataSource{
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}
