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
    
    fileprivate var topPositionOfPlayerView: CGFloat = -90
    
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
        //self.view.backgroundColor = .clear
        
        newPlayer ? playerChanged() : musicPlayerPlayStateDidChange(mPlayer.playerState, animate: false)
        
        


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.topPositionOfPlayerView = -self.miniPlayerView.frame.height
        self.view.frame = CGRect(x: 0, y: self.topPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height - self.topPositionOfPlayerView)
    }
    
    override func viewDidLayoutSubviews() {
        //self.view.frame = CGRect(x: 0, y: self.topPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height - self.topPositionOfPlayerView)
    }
    
    func loadStation(audioStation: FMStation?, isNew: Bool) {
        guard let audioStation = audioStation else { return }
        currentAudioStation = audioStation
        newPlayer = isNew
        
    }
    
    func playerChanged() {
        guard let musicUrlString = currentAudioStation?.streamURL else { return }
        mPlayer.musicUrl = URL(string: musicUrlString)
        buttonPlayPause.setImage(UIImage(named: "audio_pause"), for: .normal)
    }
    
    //MARK:- Private methods
    
    private func addPanGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        
    }
    
    var originalPosition: CGPoint?
    @objc func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer){
        
        
        let translation = gestureRecognizer.translation( in: self.view)
        let velocity = gestureRecognizer.velocity(in: self.view)
        let y = self.view.frame.minY
        
        //translate y postion when drag within topPositionOfPlayerView to bottomPositionOfPlayerView
        if (y + translation.y >= topPositionOfPlayerView) && (y + translation.y <= bottomPositionOfPlayerView) {
            
            self.view.frame = CGRect(x: 0, y: y + translation.y, width: self.view.frame.width, height: self.view.frame.height)
            gestureRecognizer.setTranslation(CGPoint(x:0,y:0), in: self.view)
        }
        
        if gestureRecognizer.state != .ended{ return}
        
     
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction], animations: {
            
            if velocity.y < -500{
                self.view.frame = CGRect(x: 0, y: self.topPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
                self.view.setNeedsLayout()
                self.view.setNeedsDisplay()
            }else if velocity.y > 500{
                self.view.frame = CGRect(x: 0, y: self.bottomPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
                self.view.setNeedsLayout()
                self.view.setNeedsDisplay()
            }else{
                
                if y + translation.y <= ((self.view.frame.height/2) + self.topPositionOfPlayerView/2){
                    
                    self.view.frame = CGRect(x: 0, y: self.topPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
                    self.view.setNeedsLayout()
                    self.view.setNeedsDisplay()
                }else{
                    
                    self.view.frame = CGRect(x: 0, y: self.bottomPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
                    self.view.setNeedsLayout()
                    self.view.setNeedsDisplay()
                }
            }
        }, completion: nil)
        
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
        if mPlayer.isPlaying {
            buttonPlayPause.setImage(UIImage(named: "audio_pause"), for: .normal)
        } else {
            buttonPlayPause.setImage(UIImage(named: "audio_play"), for: .normal)
        }
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
