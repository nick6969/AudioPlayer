//
//  PlayControlVC.swift
//  AudioPlay
//
//  Created by Nick on 3/30/21.
//

import UIKit
import AVFoundation
import MediaPlayer

final class PlayControlVC: DemoVC {
    
    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(playButton)
        stackView.addArrangedSubview(pauseButton)
        stackView.addArrangedSubview(upSpeedButton)
        stackView.addArrangedSubview(lowSpeedButton)
        stackView.addArrangedSubview(skipBackwardButton)
        stackView.addArrangedSubview(skipForwardButton)
        stackView.addArrangedSubview(playAtRateButton)
        stackView.addArrangedSubview(volumeProgressView)
        return stackView
    }()

    private lazy var playButton: UIButton = getButton("Play")
    private lazy var pauseButton: UIButton = getButton("Pause")
    private lazy var upSpeedButton: UIButton = getButton("Trun Speed to Up")
    private lazy var lowSpeedButton: UIButton = getButton("Trun Speed to Low")
    private lazy var skipBackwardButton: UIButton = getButton("Skip Backward")
    private lazy var skipForwardButton: UIButton = getButton("Skip Forward")
    private lazy var playAtRateButton: UIButton = getButton("Play At Specified Rate")
    private let volumeProgressView: MPVolumeView = {
        let slider: MPVolumeView = MPVolumeView()
        slider.tintColor = .darkGray
        slider.backgroundColor = .blue
        return slider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stackView)
        stackView.mLaySafe(pin: .init(top: 20, leading: 20, bottom: 20, trailing: 20))
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didPlayToEnd(_:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didFailedToPlayToEndTime(_:)),
                                               name: .AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)
        setupRemoteCommand()
        do {
            try setupPlay(with: TEST_M3U8_URL)
        } catch {
            print(msg: "Failed to set audio session category.")
            print(msg: error)
        }
    }
    
    override func setupPlayer() {
        PlayerKeyPath.allCases.forEach {
            playerAddObserver(keyPath: $0)
        }
        addPeriodicTimeObserver()
    }
    
    private func getButton(_ title: String) -> UIButton {
        let button: UIButton = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        return button
    }

    @objc
    private func didTap(_ button: UIButton) {
        switch button {
        case playButton: play()
        case pauseButton: pause()
        case upSpeedButton: upSpeed()
        case lowSpeedButton: lowSpeed()
        case skipForwardButton: skipForward()
        case skipBackwardButton: skipBackward()
        case playAtRateButton: playAtSpecifiedRate()
        default:
            break
        }
    }
    
    @objc
    func didPlayToEnd(_ notification: Notification) {
        print(msg: notification.object) // This is AVPlayerItem
    }

    @objc
    func didFailedToPlayToEndTime(_ notification: Notification) {
        print(msg: notification.userInfo)
        let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
        print(msg: error)
    }
    
    func setupRemoteCommand() {

        let center = MPRemoteCommandCenter.shared()

        center.previousTrackCommand.isEnabled = false
        center.nextTrackCommand.isEnabled = false

        center.skipForwardCommand.isEnabled = true
        center.skipForwardCommand.preferredIntervals = [NSNumber(15)]
        center.skipForwardCommand.addTarget(self, action: #selector(skipForwardCommand(_:)))

        center.skipBackwardCommand.isEnabled = true
        center.skipBackwardCommand.preferredIntervals = [NSNumber(15)]
        center.skipBackwardCommand.addTarget(self, action: #selector(skipBackwardCommand(_:)))

        center.playCommand.isEnabled = true
        center.playCommand.addTarget(self, action: #selector(playCommand(_:)))

        center.pauseCommand.isEnabled = true
        center.pauseCommand.addTarget(self, action: #selector(pauseCommand(_:)))

        center.changePlaybackPositionCommand.isEnabled = true
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            let time: TimeInterval = positionEvent.positionTime
            self.player.seek(to: time.cmTime)
            return .success
        }
    }

    @objc
    func skipForwardCommand(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        skipForward()
        return .success
    }
    
    @objc
    func skipBackwardCommand(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        skipBackward()
        return .success
    }

    @objc
    func playCommand(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        play()
        return .success
    }

    @objc
    func pauseCommand(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        pause()
        return .success
    }

    func updateSystemPlayInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: "iOS@Taipei",
            MPMediaItemPropertyAlbumTitle: "Nick",
            MPNowPlayingInfoPropertyPlaybackRate: self.player.rate,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: self.player.currentTime().timeInterval,
            MPMediaItemPropertyPlaybackDuration: self.player.currentItem?.duration.seconds ?? 180,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: CGSize(width: 100, height: 100)) { size -> UIImage in
                print(size)
                return UIImage()
            }
        ]
    }
}

extension PlayControlVC {
    
    func play() {
        player.play()
        updateSystemPlayInfo()
    }
    
    func pause() {
        player.pause()
    }
    
    func upSpeed() {
        player.rate += 0.5
    }
    
    func lowSpeed() {
        player.rate -= 0.5
    }
    
    func skipForward() {
        player.seek(to: player.currentTime() + CMTime(seconds: 15, preferredTimescale: 1000), completionHandler: { success in
            if success {
                print(msg: "seek time success.")
            } else {
                print(msg: "seek time failure.")
            }
        })
    }
    
    func skipBackward() {
        player.seek(to: player.currentTime() - CMTime(seconds: 15, preferredTimescale: 1000), completionHandler: { success in
            if success {
                print(msg: "seek time success.")
            } else {
                print(msg: "seek time failure.")
            }
        })
    }
    
    func playAtSpecifiedRate() {
        player.playImmediately(atRate: 2)
    }
    
}
