//
//  MiniPlayer.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/21/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import Foundation
import UIKit


//protocol

class MiniPlayer: UIView {
    
    //MARK:- IB Outlets
    @IBOutlet weak var imageAlbumArt: UIImageView!
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var labelArtistTitle: UILabel!
    
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    
    @IBOutlet weak var buttonDismissPlayer: UIButton!
    
    //MARK: Delegate
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    //MARK:- Load view
    class func loadFromNib() -> MiniPlayer {
        return (Bundle.main.loadNibNamed("MiniPlayer", owner: self, options: nil)![0] as? MiniPlayer)!
    }
    
    //MARK:- IBOutlet actions
}



