//
//  AudioPlayer.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/18/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import Foundation
import UIKit

protocol AudioPlayerDelegate: class {
    
    func playerStateDidChange(_ musicPlayerState: MusicPlayerState)
    func playbackStateDidChange(_ musicPlaybackState: MusicPlaybackState )
    
}

class AudioPlayer {
    
    weak var delegate: AudioPlayerDelegate?
    
    let player = MusicPlayer.shared
    var audioStation: FMStation?
    
    init() {
        player.delegate = self
    }
}


extension AudioPlayer: MusicPlayerDelegate {
    func musicPlayer(_ player: MusicPlayer, musicPlaybackStateDidChange state: MusicPlaybackState) {
        delegate?.playbackStateDidChange(state)
    }
    
    func musicPlayer(_ player: MusicPlayer, musicPlayerStateDidChange state: MusicPlayerState) {
        delegate?.playerStateDidChange(state)
    }
    
    

    
    

    
    
}
