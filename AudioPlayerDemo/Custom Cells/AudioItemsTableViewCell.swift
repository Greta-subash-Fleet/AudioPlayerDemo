//
//  AudioItemsTableViewCell.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/17/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import UIKit

class AudioItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var imageAudioItem: UIImageView!
    @IBOutlet weak var labelAudioTitle: UILabel!
    @IBOutlet weak var labelAudioAlbum: UILabel!
    @IBOutlet weak var labelAudioArtist: UILabel!
    @IBOutlet weak var buttonPlayPause: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCells(_ fmStations: FMStation?) {
        self.labelAudioTitle.text = fmStations?.mediaTitle
        self.labelAudioAlbum.text = fmStations?.mediaArt
        self.labelAudioArtist.text = fmStations?.mediaArt
    }

}
