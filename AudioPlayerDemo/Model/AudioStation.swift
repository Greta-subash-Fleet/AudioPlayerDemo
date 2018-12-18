//
//  AudioStation.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/18/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import Foundation

struct FMStation: Codable {
    
    var name: String?
    var streamURL: String?
    
    init(name: String, streamURL: String) {
        self.name = name
        self.streamURL = streamURL
        
    }
    
}

extension FMStation: Equatable {
    
    static func ==(lhs: FMStation, rhs: FMStation) -> Bool {
        return (lhs.name == rhs.name) && (lhs.streamURL == rhs.streamURL)
    }
}
