//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 27/05/21.
//

import Foundation
import UIKit

// Class: PlaybackPresenter
final class PlaybackPresenter{
    // Individual Audio Track
    static func startPlayback(
        from viewController: UIViewController,
        track: AudioTrack
    ){
        // VC: PlayerViewController
        let vc = PlayerViewController()
        viewController.present(vc, animated: true, completion: nil)
    }
    // Album
    static func startPlayback(
        from viewController: UIViewController,
        tracks: [AudioTrack]
    ){
        // VC: PlayerViewController
        let vc = PlayerViewController()
        viewController.present(vc, animated: true, completion: nil)
    }

}
