//
//  PlayerViewController.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/20/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import UIKit

//MARK:- Protocol
protocol PlayingVCDelegate: class {
    func didPressPlayButton()
    func didPressPreviousButton()
    func didPressNextButton()
    
}

class PlayerViewController: UIViewController {
    
    //MARK:- IB outlets
    ///mini player top
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var imageMiniAlbumArt: UIImageView!
    @IBOutlet weak var labelMiniSongTitle: UILabel!
    @IBOutlet weak var labelMiniArtistTitle: UILabel!
    @IBOutlet weak var buttonMiniPrevious: UIButton!
    @IBOutlet weak var buttonMiniPlayPause: UIButton!
    @IBOutlet weak var buttonMiniNext: UIButton!
    
    ///main player
    @IBOutlet weak var albumArtView: UIView!
    @IBOutlet weak var imageAlbumArt: UIImageView!
    @IBOutlet weak var buttonDismissPlayer: UIButton!
    
    @IBOutlet weak var albumInfoView: UIView!
    @IBOutlet weak var labelSongTitle: UILabel!
    @IBOutlet weak var labelArtistTitle: UILabel!
    
    @IBOutlet weak var playerControlView: UIView!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var labelEndTime: UILabel!
    
    @IBOutlet weak var buttonRepeat: UIButton!
    @IBOutlet weak var buttonPrevious: UIButton!
    @IBOutlet weak var buttonPlayPause: UIButton!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var buttonShuffle: UIButton!
    
    
    //MARK:-
    weak var delegate: PlayingVCDelegate?
    
    var currentAudioStation: FMStation?
    
    let mPlayer = MusicPlayer.shared
    var newPlayer = true
    
    fileprivate var topPositionOfPlayerView: CGFloat = -70
    
    fileprivate var bottomPositionOfPlayerView: CGFloat {
        
        let appDelagate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelagate.window
        
        var yPosition: CGFloat = 0
        if #available(iOS 11.0, *) {
            if let bottom = window?.safeAreaInsets.bottom, bottom > 0{
                yPosition = bottom
            }
        }
        
        return UIScreen.main.bounds.height + self.topPositionOfPlayerView - yPosition
    }

    
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPanGesture()
        
        newPlayer ? playerChanged() : musicPlayerPlayStateDidChange(mPlayer.playerState, animate: false)


        // Do any additional setup after loading the view.
    }
    
    func loadStation(audioStation: FMStation?, isNew: Bool) {
        guard let audioStation = audioStation else { return }
        currentAudioStation = audioStation
        newPlayer = isNew
    }
    
    func playerChanged() {
        guard let musicUrlString = currentAudioStation?.streamURL else { return }
        mPlayer.musicUrl = URL(string: musicUrlString)
    }
    
    //MARK:- Private methods
    
    private func addPanGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        
    }
    
    var originalPosition: CGPoint?
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer){
        //var originalPosition: CGPoint?
        let translation = gestureRecognizer.translation(in: view)
        let y = self.view.frame.minY
        
        if (y + translation.y >= -70) && (y + translation.y <= 200) {
            
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: self.view.frame.width, height: self.view.frame.height)
            gestureRecognizer.setTranslation(CGPoint(x:0,y:0), in: self.view)
        }
        
        if gestureRecognizer.state == .began {
            originalPosition = view.center
            //currentPositionTouched = panGesture.location(in: view)
        } else if gestureRecognizer.state == .changed {
            view.frame.origin = CGPoint(
                x:  view.frame.origin.x,
                y:  view.frame.origin.y + translation.y
            )
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.view)
        } else if gestureRecognizer.state == .ended {
            let velocity = gestureRecognizer.velocity(in: view)
            if velocity.y >= 150 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.view.frame.origin = CGPoint(
                            x: self.view.frame.origin.x,
                            y: self.view.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.center = self.originalPosition!
                })
            }
        }
        
    }
    
    
    
    
    
    //MARK:- IB Actions Main Player
    @IBAction func buttonRepeatTapped(_ sender: Any) {
        print("Repeat Tapped")
    }
    
    @IBAction func buttonPreviousTapped(_ sender: Any) {
        self.delegate?.didPressPreviousButton()
    }
    
    @IBAction func buttonPlayPauseTapped(_ sender: Any) {
       self.delegate?.didPressPlayButton()
    }
    
    @IBAction func buttonNextTapped(_ sender: Any) {
        self.delegate?.didPressNextButton()
    }
    
    @IBAction func buttonShuffleTapped(_ sender: Any){
        print("Shuffle Tapped")
    }
    
    @IBAction func buttonDismissPlayerTapped(_ sender: Any) {
        print("Dismiss")
    }
    
    
    //MARK:- IB Actions in mini-player top
    
    
    //
    func musicPlayerPlaybackStateDidChange(_ musicPlaybackState: MusicPlaybackState, animate: Bool) {
        var message: String?
        
        switch musicPlaybackState {
        case .paused:
            message = ""
        default:
            message = ""
        }
        
    }
    
    func musicPlayerPlayStateDidChange(_ musicPlayerState: MusicPlayerState, animate: Bool) {
        var message: String?
        switch musicPlayerState {
            
        case .readyToPlay, .loadingFinished:
            message = ""
            
        default:
            message = ""
        }
        musicPlayerPlaybackStateDidChange(mPlayer.musicPlaybackState, animate: animate)
    }
    
    func isAudioPlayingChanged(_ isPlaying: Bool) {
        buttonPlayPause.isSelected = isPlaying
    }
    

}


class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}
