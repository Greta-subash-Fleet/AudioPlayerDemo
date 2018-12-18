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
    
    init() {
        
    }
}

extension AudioPlayer: AudioPlayerDelegate {
    
    func playbackStateDidChange(_ musicPlaybackState: MusicPlaybackState) {
        <#code#>
    }
    
    func playerStateDidChange(_ musicPlayerState: MusicPlayerState) {
        <#code#>
    }
    
    

    
    
}
