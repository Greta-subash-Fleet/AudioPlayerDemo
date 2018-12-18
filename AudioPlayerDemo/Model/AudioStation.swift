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
    var link: String?
    
    init(name: String, link: String) {
        self.name = name
        self.link = link
        
    }
    
}

extension FMStation: Equatable {
    
    static func ==(lhs: FMStation, rhs: FMStation) -> Bool {
        return (lhs.name == rhs.name) && (lhs.link == rhs.link)
    }
}
