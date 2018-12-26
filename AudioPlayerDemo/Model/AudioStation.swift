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


//struct FMStation: Codable {
//
//    var mediaId: String?
//    var mediaTitle: String?
//    var mediaUrl: String?
//    var mediaArt: String?
//
//    init(mediaId: String, mediaTitle: String, mediaUrl: String, mediaArt: String) {
//        self.mediaId = mediaId
//        self.mediaTitle = mediaTitle
//        self.mediaUrl = mediaUrl
//        self.mediaArt = mediaArt
//    }
//
//}
//
//extension FMStation: Equatable {
//    static func ==(lhs: FMStation, rhs: FMStation) -> Bool {
//        return (lhs.mediaId == rhs.mediaId) && (lhs.mediaTitle == rhs.mediaTitle) && (lhs.mediaUrl == rhs.mediaUrl) && (lhs.mediaArt == rhs.mediaArt)
//    }
//}
