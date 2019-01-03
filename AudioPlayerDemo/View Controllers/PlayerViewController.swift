//
//  PlayerViewController.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/20/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import UIKit
import MediaPlayer
//MARK:- Protocol
protocol PlayingVCDelegate: class {
    func didPressPlayButton()
    func didPressPreviousButton()
    func didPressNextButton()
    func didPressShuffleButton(_ sender: UIButton)
   
    
}

class PlayerViewController: UIViewController {
    
    //MARK:- IB outlets
    ///mini player top
    @IBOutlet weak var buttonShowFMPlayer: UIButton!
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
    
    fileprivate var topPositionOfPlayerView: CGFloat = -100
    
    var bottomPositionOfPlayerView: CGFloat {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        
        var yPosition: CGFloat = 0
        if #available(iOS 11.0, *) {
            if let bottom = window?.safeAreaInsets.bottom, bottom > 0{
                yPosition = bottom
            }
        }
        
        return UIScreen.main.bounds.height + self.topPositionOfPlayerView - yPosition
    }
    
    //MARK:- List
    fileprivate var audioItemSuffleListArray = [Int]()

    
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.addPanGesture()
        self.showOrHideControls()
        
        //self.view.backgroundColor = .clear
        
        newPlayer ? playerChanged() : musicPlayerPlayStateDidChange(mPlayer.playerState, animate: false)
        
        


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.topPositionOfPlayerView = -self.miniPlayerView.frame.height
        self.view.frame = CGRect(x: 0, y: -100, width: self.view.frame.width, height: self.view.frame.height + 100)
        print(self.view.frame)
    }
    
    override func viewDidLayoutSubviews() {
        //self.view.frame = CGRect(x: 0, y: self.topPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height - self.topPositionOfPlayerView)
    }
    
    
    fileprivate func showOrHideControls() {
        
      let hideControls = isFMPlayer
        if hideControls {
            buttonShowFMPlayer.isHidden = true
        } else {
            self.addPanGesture()
        }
    }
    
    ///to display mini player when player list is clicked in another controller
    public func show(_ view : UIView){
        
        self.view.frame = CGRect(x: 0, y: self.bottomPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height - self.topPositionOfPlayerView)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window!
        if !self.view.isDescendant(of: window) {
            window.addSubview(self.view)
        }
    }
    
    func loadStation(audioStation: FMStation?, isNew: Bool = true) {
        guard let audioStation = audioStation else { return }
        currentAudioStation = audioStation
        newPlayer = isNew
        self.playerChanged()
        if !newPlayer {
            //self.labelEndTime.text = mPlayer.currentTime
        }
        
    }
    
    func playerChanged() {
        guard let musicUrlString = currentAudioStation?.mediaUrl else { return }
        //guard let musicUrlString = currentAudioStation?.streamURL else { return }
        mPlayer.musicUrl = URL(string: musicUrlString)
        
        

        //self.setUpTimeObserver()
        //buttonPlayPause.setImage(UIImage(named: "audio_pause"), for: .normal)
    }
    
    //MARK:- Private methods
    ///time observer for player slider

    

        

    

    
    ///pan gesture
    private func addPanGesture() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(gesture)
        self.presentationController?.containerView?.isUserInteractionEnabled = true
        
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
                print(self.view.frame.height)
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.view.setNeedsLayout()
                self.view.setNeedsDisplay()
            }else if velocity.y > 500{
                self.view.frame = CGRect(x: 0, y: self.bottomPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                 print(self.view.frame.height)
                self.view.setNeedsLayout()
                self.view.setNeedsDisplay()
            }else{
                
                if y + translation.y <= ((self.view.frame.height/2) + self.topPositionOfPlayerView/2){
                    
                    self.view.frame = CGRect(x: 0, y: self.topPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                     print(self.view.frame.height)
                    self.view.setNeedsLayout()
                    self.view.setNeedsDisplay()
                }else{
                    
                    self.view.frame = CGRect(x: 0, y: self.bottomPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                     print(self.view.frame.height)
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
    
    @IBAction func buttonPlayPauseTapped(_ sender: UIButton) {
        
       self.delegate?.didPressPlayButton()
        sender.isSelected = !sender.isSelected
        
        if mPlayer.isPlaying {
            buttonPlayPause.setImage(UIImage.imagePauseIcon, for: .normal)
            buttonMiniPlayPause.setImage(UIImage.imagePauseIcon, for: .normal)
            
        } else {
            buttonPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
            buttonMiniPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
        }
    }
    
    @IBAction func buttonNextTapped(_ sender: Any) {
        self.delegate?.didPressNextButton()
    }
    
    @IBAction func buttonShuffleTapped(_ sender: UIButton){
        print("Shuffle Tapped")
        sender.isSelected = !sender.isSelected
        _ = sender.isSelected ? "\(sender.setImage(UIImage.imageRepeatIcon, for: UIControl.State()))" : "\(sender.setImage(UIImage.imageShuffleIcon, for: UIControl.State()))"
        self.delegate?.didPressShuffleButton(sender)
        
        
    }
    //observer for slider and slider timings
    
    
    @IBAction func buttonDismissPlayerTapped(_ sender: Any) {
        print("Dismiss")
        //self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.07, options: [.transitionCurlDown], animations: {[weak self]  in
            guard let self = self else { return }
            
            self.view.frame = CGRect(x: 0, y: self.bottomPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
            print(self.view.frame.height)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            }, completion: nil)
    }
    
    
    //MARK:- IB Actions in mini-player top
    
    @IBAction func buttonFMPlayerTapped(_ sender: UIButton) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.07, options: [.transitionCurlUp], animations: {[weak self]  in
            guard let self = self else { return }
            
            self.view.frame = CGRect(x: 0, y: self.topPositionOfPlayerView, width: self.view.frame.width, height: self.view.frame.height)
            print(self.view.frame.height)
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            
            }, completion: nil)
    }
    

    @IBAction func buttonMiniPreviousTapped(_ sender: UIButton) {
        print("Previous tapped in mini player")
        self.delegate?.didPressPreviousButton()
    }
    
    
    @IBAction func buttonMiniPlayPauseTapped(_ sender: UIButton) {
        print("Play pause tapped in mini player")
//        sender.isSelected = !sender.isSelected
//        _ = sender.isSelected ? "\(sender.setImage(UIImage(named: "audio_pause"), for: UIControl.State()))" : "\(sender.setImage(UIImage(named: "audio_play"), for: UIControl.State()))"
//        self.delegate?.didPressPlayButton()
        
        self.delegate?.didPressPlayButton()
        sender.isSelected = !sender.isSelected
        if mPlayer.isPlaying {
            buttonPlayPause.setImage(UIImage.imagePauseIcon, for: .normal)
            buttonMiniPlayPause.setImage(UIImage.imagePauseIcon, for: .normal)
            
        } else {
            buttonPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
            buttonMiniPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
        }

    }
    
    @IBAction func buttonMiniNextTapped(_ sender: UIButton) {
        print("Next tapped in mini player")
        self.delegate?.didPressNextButton()

    }
    
    
    
    
    
    
    //MARK:- Time observer for slider values
    ///notification set up
    private var observer: Any?
    
    private func setUpTimeObserverForPlayerItem() {
        
//        if let observer = self.observer {
//            mPlayer.player?.removeTimeObserver(observer)
//        }
        observer = nil
        
        self.labelStartTime.text = "__:__"
        self.labelEndTime.text = "__:__"
        
        self.playerSlider.minimumValue = 0
        self.playerSlider.value = 0
        let interval: CMTime = CMTimeMake(value: 1, timescale: 10)
        self.observer = self.mPlayer.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let `self` = self else { return }
            let currentDuration: Float64 = CMTimeGetSeconds(time)
            self.playerSlider.value = CFloat(currentDuration)
            self.setUpSliderValues()
            
        }
    }
    
    private func setUpSliderValues() {
        
        guard let currentItem = self.mPlayer.player?.currentItem else { return }
        
        //get time in seconds
        let playhead = currentItem.currentTime().seconds
        let duration = currentItem.duration.seconds
        
        //format time
        if playhead.isFinite, duration.isFinite {
            let currentTime = self.calculateTimeFromNSTimeInterval(playhead)
            self.labelStartTime.text = "\(currentTime.minute):\(currentTime.second)"
            
            let totalTime = self.calculateTimeFromNSTimeInterval(duration)
            self.labelEndTime.text = "\(totalTime.minute):\(totalTime.second)"
            self.playerSlider.maximumValue = Float(duration)
        } else {
            self.playerSlider.value = 0
            self.labelStartTime.text = "NaN:NaN"
            self.labelEndTime.text = "NaN:NaN"
        }
        
        if duration.isFinite {
//            let totalTime = self.calculateTimeFromNSTimeInterval(duration)
//            self.labelEndTime.text = "\(totalTime.minute):\(totalTime.second)"
//            self.playerSlider.maximumValue = Float(duration)
        }
        
    }
    


    
    
    
    
    //This returns song length
    private func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        //         let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        //        var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }

    
    //MARK:- Player playback states
    ///music playback states
    func musicPlayerPlaybackStateDidChange(_ musicPlaybackState: MusicPlaybackState, animate: Bool) {
        var message: String?
        
        switch musicPlaybackState {
        case .paused:
            message = "FM Player Paused."

            
            if (buttonPlayPause != nil) {
                buttonPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
                //buttonPlayPause.setImage(UIImage(named: "audio_play"), for: .normal)
            }
            if (buttonMiniPlayPause != nil) {
                buttonMiniPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
                //buttonMiniPlayPause.setImage(UIImage(named: "audio_play"), for: .normal)
            }
        case .playing:
            print(message ?? "")
            if (buttonPlayPause != nil) {
                buttonPlayPause.setImage(UIImage.imagePauseIcon, for: .normal)
                //buttonPlayPause.setImage(UIImage(named: "audio_pause"), for: .normal)
            }
            if (buttonMiniPlayPause != nil) {
                buttonMiniPlayPause.setImage(UIImage.imagePauseIcon, for: .normal)
                //buttonMiniPlayPause.setImage(UIImage(named: "audio_pause"), for: .normal)
            }

            self.setUpTimeObserverForPlayerItem()
        default:
            message = ""
        }
        

        isAudioPlayingChanged(mPlayer.isPlaying)
        
    }
    
    func musicPlayerPlayStateDidChange(_ musicPlayerState: MusicPlayerState, animate: Bool) {
        var message: String?
        switch musicPlayerState {
            
        case .readyToPlay, .loadingFinished:
            musicPlayerPlaybackStateDidChange(mPlayer.musicPlaybackState, animate: animate)
            
        case .error:
            message = "Error playing FM Player."
            //show toast
            HelperMethods.showToast(message: message ?? "Test")
            
            if (buttonPlayPause != nil) {
                //buttonPlayPause.setImage(UIImage(named: "audio_play"), for: .normal)
                buttonPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
            }
            
            if (buttonMiniPlayPause != nil) {
                //buttonMiniPlayPause.setImage(UIImage(named: "audio_play"), for: .normal)
                buttonMiniPlayPause.setImage(UIImage.imagePlayIcon, for: .normal)
            }
            
        case .loading:
            message = "Loading FM Player."
            //show toast
            HelperMethods.showToast(message: message ?? "")
            
        case .urlNotSet:
            message = "Invalid Player URL."
            //show toast
            HelperMethods.showToast(message: message ?? "")
            
        default:
            message = ""
        }
        //musicPlayerPlaybackStateDidChange(mPlayer.musicPlaybackState, animate: animate)
        
        //show toast message
   
        
        //HelperMethods.showToast(message: message ?? "Test")
    }
    
    func isAudioPlayingChanged(_ isPlaying: Bool) {
        buttonPlayPause.isSelected = isPlaying
        buttonMiniPlayPause.isSelected = isPlaying
    }
    

}



