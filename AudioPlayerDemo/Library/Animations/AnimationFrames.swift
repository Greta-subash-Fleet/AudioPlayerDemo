//
//  AnimationFrames.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/28/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import Foundation
import UIKit

class AnimationFrames {
    
    class func createFrames() -> [UIImage] {
        
        // Setup "Now Playing" Animation Bars
        var animationFrames = [UIImage]()
        for i in 0...3 {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationFrames.append(image)
            }
        }
        
        for i in stride(from: 2, to: 0, by: -1) {
            if let image = UIImage(named: "NowPlayingBars-\(i)") {
                animationFrames.append(image)
            }
        }
        return animationFrames
    }
    
}
