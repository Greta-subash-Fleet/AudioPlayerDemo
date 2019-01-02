//
//  MusicPlayer.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/18/18.
//  Copyright © 2018 NITV. All rights reserved.
//

//
//  Created by Fethi El Hassasna on 2017-11-11.
//  Copyright © 2017 Fethi El Hassasna (@fethica). All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

//MARK:- MusicPlaybackState
@objc public enum MusicPlaybackState: Int {
    
    case playing
    
    case paused
    
    case stopped
    
    case repeatOn
    
    case repeatOff
    
    case suffleOn
    
    case suffleOff
    
    public var description: String {
        switch self {
        case .playing:
            return "Player is playing."
            
        case .paused:
            return "Player is paused."
            
        case .stopped:
            return "Player is stopped."
            
        case .repeatOn:
            return "Repeat On."
            
        case .repeatOff:
            return "Repeat Off."
            
        case .suffleOn:
            return "Suffle On."
            
        case .suffleOff:
            return "Suffle Off."
        }
    }
    
}


//MARK:- MusicPlayer state

//music player status enum
@objc public enum MusicPlayerState: Int {
    
    case urlNotSet
    
    case readyToPlay
    
    case loading
    
    case loadingFinished
    
    case error
    
    public var description: String {
        switch self {
        case .urlNotSet:
            return "URL is not set."
            
        case .readyToPlay:
            return "Ready to play."
            
        case .loading:
            return "Loading..."
            
        case .loadingFinished:
            return "Loading Finished."
            
        case .error:
            return "Error"
        }
    }
    
}


//MARK:- MusicPlayer Delegate

@objc public protocol MusicPlayerDelegate: class {
    
    ///called when player changes playing state
    func musicPlayer(_ player: MusicPlayer, musicPlaybackStateDidChange state: MusicPlaybackState)
    
    ///called when player changes state
    func musicPlayer(_ player: MusicPlayer, musicPlayerStateDidChange state: MusicPlayerState)
    
    ///called when current player item changes
    @objc optional func musicPlayer(_ player: MusicPlayer, playerItemDidChange url: URL?)
    
    
}



//Mark:-

open class MusicPlayer: NSObject {
    
    public static let shared = MusicPlayer()
    
    open weak var delegate: MusicPlayerDelegate?
    
    open var musicUrl: URL? {
        didSet {
            musicUrlDidChange(url: musicUrl)
        }
    }
    
    
    ///check if the player is playing
    open var isPlaying: Bool {
        
        switch musicPlaybackState {
        case .playing:
            return true
            
        case .paused, .stopped:
            return false
            
        default:
            return false
            

        }
    }
    
    ///current player state of MusicPlayer
    open private(set) var playerState = MusicPlayerState.urlNotSet {
        didSet {
            guard oldValue != playerState else { return }
            delegate?.musicPlayer(self, musicPlayerStateDidChange: playerState)
        }
    }
    
    
    //current playback state of MusicPlayer
    open private(set) var musicPlaybackState = MusicPlaybackState.stopped {
        didSet {
            guard oldValue != musicPlaybackState else { return }
            delegate?.musicPlayer(self, musicPlaybackStateDidChange: musicPlaybackState)
        }
    }
    
    //MARK:- Private properties, for avplayer
    open var player: AVPlayer?
    
    private var lastplayerItem: AVPlayerItem?
    
    // Check for headphones, used to handle audio route change
    private var headphonesConnected: Bool = false
    
    //default player item
    private var playerItem: AVPlayerItem? {
        didSet {
            self.playerItemDidChange()
        }
    }
    
    ///reachability to handle network interruption
    private let reachability = Reachability()!
    
    ///current network state
    private var isConnected: Bool = false
    
    
    //MARK:- Init
//    var updater: CADisplayLink! = nil
//    var progress: UISlider!
    private override init() {
        super.init()
        self.setUpNotifications()
//        updater = CADisplayLink(target: self, selector: #selector(MusicPlayer.updateProgressView))
//        updater.preferredFramesPerSecond = 1
//        updater.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
    }
    
    @objc func updateProgressView() {
        print("Update slider")


    }
    
    
    //MARK:- Music player control methods
    
    open func play() {
        guard let player = player else { return }
        
        if player.currentItem == nil, playerItem != nil {
            player.replaceCurrentItem(with: playerItem)
            
        }
        player.play()
        musicPlaybackState = .playing
    }
    
    
    open func pause() {
        guard let player = player else {
            return
        }
        player.pause()
        musicPlaybackState = .paused
    }
    
    
    open func stop() {
        guard let player = player else { return }
        player.replaceCurrentItem(with: nil)
        musicPlaybackState = .stopped
    }
    
    
    open func togglePlaying() {
        isPlaying ? pause() : play()
    }
    
    
    open func isSuffle() {
        
    }
    
    open func isRepeat() {
        
    }
    
    
    //MARK:- Private helper methods
    private func musicUrlDidChange(url: URL?) {
        self.resetMusicPlayer()
        guard let url = url else {
            playerState = .error
            return
            
        }
        playerState = .loading
        preparePlayer(with: AVAsset(url: url)) { (success, asset) in
            guard success, let asset = asset else {
                self.resetMusicPlayer()
                self.playerState = .error
                return
            }
            self.setUpMusicPlayer(with: asset)
        }
        
        
        
    }
    
    ///set up avplayer
    private func setUpMusicPlayer(with asset: AVAsset) {
        if player == nil {
            player = AVPlayer()
        }
        playerItem = AVPlayerItem(asset: asset)
        self.play()
        //print(player?.currentItem?.asset.duration.seconds)
        //self.setUpNotifications()
    }
    
    
    
    ///reset all observers and create new ones
    private func playerItemDidChange() {
        
    }
    
    
    
    ///prepare player from passed av asset
    private func preparePlayer(with asset: AVAsset?, completionHandler: @escaping(_ isPlayable: Bool, _ asset: AVAsset?) -> ()) {
        
        guard let asset = asset else {
            completionHandler(false, nil)
            return
        }
        
        let requestedKey = ["playable"]
        asset.loadValuesAsynchronously(forKeys: requestedKey) {
            
            DispatchQueue.main.async {
                
                var error: NSError?
                let keystatus = asset.statusOfValue(forKey: "playable", error: &error)
                if keystatus == AVKeyValueStatus.failed || !asset.isPlayable {
                    completionHandler(false, nil)
                    return
                    
                }
                
                completionHandler(true, asset)
            }
        }
        
    }
    
    ///reload current item
    private func reloadMusicPlayer() {
        player?.replaceCurrentItem(with: nil)
        player?.replaceCurrentItem(with: playerItem)
    }
    
    ///set player item nil
    private func resetMusicPlayer() {
        self.stop()
        playerItem = nil
        lastplayerItem = nil
        player = nil
    }
    
    
    deinit {
        self.resetMusicPlayer()
        //remove notification observers as well
    }
    
    
    ///notification set up
    var observer: Any?
    var musicSlider: UISlider?
    var currentDuration: String?
    var currentTime: String? {
        didSet {
            self.displayCurrentTime()
        }
    }
    var totalDuration: String?
    
    func setUpNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
        //notificationCenter.addObserver(self, selector: #selector(replayMusicPlayer), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

    }
    
    //MARK:- Player Interruption
    ///handle audio playback interruption
    @objc private func handleInterruption(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        
        switch type {
            
        case .began:
            print("Interruption started")
            ///interruption started, playback state should pause
            DispatchQueue.main.async {
                self.pause()
            }
            
        case .ended:
            print("Interruption ended")
            ///interruption ended, playback state should resume
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            DispatchQueue.main.async {
                options.contains(.shouldResume) ? self.play() : self.pause()
            }
            
        }
        
    }
    
    ///handle route change
    @objc private func handleRouteChange(_ notification: Notification) {
        
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        
        switch reason {
            
        case .newDeviceAvailable:
            checkHeadphonesConnection(outputs: AVAudioSession.sharedInstance().currentRoute.outputs)
            
        case .oldDeviceUnavailable:
            guard let previousRoute = userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription else { return }
            checkHeadphonesConnection(outputs: previousRoute.outputs)
            
            DispatchQueue.main.async {
                self.headphonesConnected ? () : self.pause()
                
            }
            
        default:
            break
        }
    }
    
    
    ///response to route change
    private func checkHeadphonesConnection(outputs: [AVAudioSessionPortDescription]) {
        for output in outputs where output.portType == AVAudioSession.Port.headphones {
            headphonesConnected = true
            break
        }
        headphonesConnected = false
    }
    
    
    //MARK:- Reachability changed
    @objc func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else { return }
        if reachability.connection != .none, !isConnected {
            self.checkNetworkInterruption()
        }
        
        isConnected = reachability.connection != .none
    }
    
    //check if playback could keep up after network interruption
    private func checkNetworkInterruption() {
        
        guard let item = playerItem,
            !item.isPlaybackLikelyToKeepUp,
            reachability.connection != .none else {
                return
        }
        
        player?.pause()
        ///wait for a second to check if reload is needed after interruption
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if !item.isPlaybackLikelyToKeepUp {
                ///reload if the current items playback is unlikely to keep up
                self.reloadMusicPlayer()
            }
            ///if t
            self.isPlaying ? self.player?.play() : self.player?.pause()
        }
    }
    
    
    
    func setUpSliderValues() {
        
        guard let currentItem = self.player?.currentItem else{
            return
        }
        
        // Get the current time in seconds
        let playhead = currentItem.currentTime().seconds
        let duration = currentItem.duration.seconds
        // Format seconds for human readable string
        
        if playhead.isFinite{
            let time = self.calculateTimeFromNSTimeInterval(playhead)
            currentDuration = "\(time.minute):\(time.second)"
            print("Current Duration: \(String(describing: currentDuration))")
            displayCurrentTime()
        }
        
        if duration.isFinite{
            
            let time = self.calculateTimeFromNSTimeInterval(duration)
            totalDuration = "\(time.minute):\(time.second)"
            print("Total Duration: \(String(describing: totalDuration))")
            self.musicSlider?.maximumValue = Float(duration)
        }
    }
    
    func displayCurrentTime() {
        //currentTime = currentDuration ?? ""
    }
    
  
    
    
    //This returns song length
    fileprivate func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        //         let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        //        var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }

    
}
