//
//  AudioItemsListViewController.swift
//  AudioPlayerDemo
//
//  Created by Subash Parajuli on 12/17/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class AudioItemsListViewController: UIViewController {
    
    //MARK: Interface Builder
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- properties
    let musicPlayer = AudioPlayer()
    
    weak var playerViewController: PlayerViewController?
    
    //MARK:- Lists
    var audioItems = [FMStation]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()

            }
        }
    }
    
    fileprivate var isShuffleOn: Bool = false
    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.getAudioItems()
        self.setUpAudioSession()
        musicPlayer.delegate = self
        
        tableView.backgroundColor = .clear
        tableView.backgroundView = nil

        // Do any additional setup after loading the view.
    }
    
    func getAudioItems() {
        self.loadAudioItemsFromJSON()
    }
    
    func loadAudioItemsFromJSON() {
        
        // Turn on network indicator in status bar
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Get the Radio Stations
        DataManager.getAudioDataWithSuccess() { (data) in
            
            // Turn off network indicator in status bar
            defer {
                DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
            }
            
            if kDebugLog { print("Stations JSON Found") }
            
            guard let data = data, let jsonDictionary = try? JSONDecoder().decode([String: [FMStation]].self, from: data), let audioArray = jsonDictionary["audioItems"] else {
                if kDebugLog { print("JSON Station Loading Error") }
                return
            }
            
            self.audioItems = audioArray
        }
    }
    
    ///set up audio session
    func setUpAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            debugPrint("AVAudio session active.")
            self.setUpRemoteCommandCenter()
            self.showMediaInfoInRemoteControl()
        } catch {
            if kDebugLog { print("audioSession could not be activated") }
            debugPrint("Error: \(error)")
        }
    }
    
    //MARK:- Remote command center controls
    func setUpRemoteCommandCenter() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { event in
            return .success
            
        }
        
        commandCenter.pauseCommand.addTarget { event in
            return .success
            
        }
        
        commandCenter.previousTrackCommand.addTarget { event in
            return .success
            
        }
        
        commandCenter.nextTrackCommand.addTarget { event in
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { event in
            return .success
        }
        
        commandCenter.changeRepeatModeCommand.addTarget { event in
            return .success
        }
        
        commandCenter.changeShuffleModeCommand.addTarget { event in
            return .success
            
        }
        
        
    }
    
    // MARK: - Remote Controls
    
    override func remoteControlReceived(with event: UIEvent?) {
        super.remoteControlReceived(with: event)
        
        guard let event = event, event.type == UIEvent.EventType.remoteControl else { return }
        
        switch event.subtype {
            
        case .remoteControlPlay:
            MusicPlayer.shared.play()
            
        case .remoteControlPause:
            MusicPlayer.shared.pause()
            
        case .remoteControlTogglePlayPause:
            MusicPlayer.shared.togglePlaying()
            
        case .remoteControlNextTrack:
            print("Next")
            
        case .remoteControlPreviousTrack:
            print("Previous")
            
            
        default:
            break
        }
    }
    
    //get index of audio items
    private func getAudioStationsCount(of station: FMStation) -> Int? {
        let audioStation = station
        guard let  audioStationIndex = audioItems.index(of: audioStation) else { return nil }
        return audioStationIndex
        
    }
    
    private func showMediaInfoInRemoteControl() {
        var nowPlayingInfo = [String : Any]()
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Audio Player"
        //nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player?.currentItem?.currentTime().seconds
        //nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player?.currentItem?.asset.duration.seconds
        //nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        if let image = UIImage(named: "LedZep") {
            if #available(iOS 10.0, *) {
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { size in
                        return image
                }
            } else {
                // Fallback on earlier versions
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
                
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func showMiniPlayer(sender: IndexPath) {
        
        let storyboard = UIStoryboard.init(name: "AudioPlayer", bundle: nil)
        playerViewController = storyboard.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerViewController
        let isNew: Bool?
        if let indexPath = sender as? IndexPath {
            musicPlayer.audioStation = audioItems[indexPath.row]
            isNew = true
        } else {
            isNew = false
        }
        playerViewController?.loadStation(audioStation: musicPlayer.audioStation, isNew: isNew!)
        playerViewController?.delegate = self
        playerViewController?.modalTransitionStyle = .flipHorizontal
        playerViewController?.modalPresentationStyle = .overCurrentContext
        self.present(playerViewController!, animated: false)
        
    }
    
}


//MARK:- Extension tableviewdatasource
extension AudioItemsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AudioItemsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AudioItemsCell", for: indexPath) as! AudioItemsTableViewCell
        cell.labelAudioTitle.text = audioItems[indexPath.row].name
        return cell
    }
    
}



extension AudioItemsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let audioUrl = URL(string: audioItems[indexPath.row].streamURL!) else { return }
//        musicPlayer.player.musicUrl = audioUrl
        
        self.showMiniPlayer(sender: indexPath)
        
    }
}

extension AudioItemsListViewController: AudioPlayerDelegate {
    func playerStateDidChange(_ musicPlayerState: MusicPlayerState) {
        playerViewController?.musicPlayerPlayStateDidChange(musicPlayerState, animate: true)
    }
    
    func playbackStateDidChange(_ musicPlaybackState: MusicPlaybackState) {
        playerViewController?.musicPlayerPlaybackStateDidChange(musicPlaybackState, animate: true)
    }
    
    
    
}


extension AudioItemsListViewController: PlayingVCDelegate {
    
    ///shuffle music
    func didPressShuffleButton(_ sender : UIButton) {
        
        if sender.isSelected {
            isShuffleOn = true
        } else {
            isShuffleOn = false
            
        }
    }
    
    
    func playMusicFromRandomIndex() {
        
        playerViewController?.buttonPrevious.isEnabled = true
        playerViewController?.buttonNext.isEnabled = true
        //let shuffledItems = audioItems.shuffled()
        let randomIndex = Int(arc4random_uniform(UInt32(audioItems.count)))
        print("Random Index: \(randomIndex)")
        musicPlayer.audioStation = audioItems[randomIndex]
        self.changeAudioItem()

    }
    
    
    ///toggle play pause
    func didPressPlayButton() {
        musicPlayer.player.togglePlaying()
    }
    
    func didPressPreviousButton() {

        print("Play previous")
        isShuffleOn ? playMusicFromRandomIndex() : playPreviousItems()
    
    }
    
    
    ///play previous
    func playPreviousItems() {
        if audioItems.count > 1 {
            playerViewController?.buttonNext.isEnabled = true
        }
        
        guard let audioIndex = getAudioStationsCount(of: musicPlayer.audioStation!) else { return }
        if audioIndex - 1 <= 0 {
            playerViewController?.buttonPrevious.isEnabled = false
        } else {
            musicPlayer.audioStation = audioItems[audioIndex - 1]
            self.changeAudioItem()
            
        }
    }
    
    
    ///play next
    func didPressNextButton() {
        print("Play next")
        isShuffleOn ? playMusicFromRandomIndex() : playNextItems()

    }
    
    
    func playNextItems() {
        if audioItems.count > 1 {
            playerViewController?.buttonPrevious.isEnabled = true
        }
        guard let audioIndex = getAudioStationsCount(of: musicPlayer.audioStation!) else { return }
        if audioIndex + 1 >= audioItems.count {
            playerViewController?.buttonNext.isEnabled = false
        } else {
            
            musicPlayer.audioStation = audioItems[audioIndex + 1]
            self.changeAudioItem()
            
        }
    }
    
    
    
    ///play the selected audio item
    func changeAudioItem() {
        if let audioPlayingVC = playerViewController {
            audioPlayingVC.loadStation(audioStation: musicPlayer.audioStation, isNew: false)
            
        } else if let audioStation = musicPlayer.audioStation {
            musicPlayer.player.musicUrl = URL(string: audioStation.streamURL ?? "")
            
        }
    }
    
    
}
