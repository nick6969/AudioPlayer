//
//  PlayEasyVC.swift
//  AudioPlay
//
//  Created by Nick on 3/30/21.
//

import UIKit
import AVFoundation

class DemoVC: UIViewController {
    
    lazy var player: AVPlayer = AVPlayer(playerItem: nil)
    
    func setupPlay(with url: URL) throws {
            
        let session: AVAudioSession = AVAudioSession.sharedInstance()
        try session.setCategory(.playback)
            
        let asset: AVURLAsset = AVURLAsset(url: url)
        let playItem: AVPlayerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playItem)
        setupPlayer()
    }
    
    func setupPlayer() { }
    func currentItemReadyToPlay() { }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case PlayerKeyPath.status.rawValue: showPlayerStatus()
        case PlayerKeyPath.itemStatus.rawValue: showPlayerItemStatus()
        case PlayerKeyPath.timeControlStatus.rawValue: showPlayerTimeControlStatus()
        case PlayerKeyPath.itemDuration.rawValue: showDuration()
        case PlayerKeyPath.rate.rawValue: showRateChange()
        default:
            break
        }
    }
        
}

extension DemoVC {
    
    func playerAddObserver(keyPath: PlayerKeyPath) {
        player.addObserver(self,
                           forKeyPath: keyPath.rawValue,
                           options: [.new, .initial],
                           context: nil)
    }

    func addPeriodicTimeObserver() {
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: Int32(NSEC_PER_SEC)), queue: .main) { time in
            print(msg: "播放器播放到 from Observer: \(time), ")
            print(msg: "播放器播放到 from Observer: \(time.timeInterval), ")
        }
    }

}

extension DemoVC {

    func showPlayerStatus() {
        switch player.status {
        case .unknown:
            print(msg: "播放器狀態 unknow")
        case .readyToPlay:
            print(msg: "播放器狀態 readyToPlay")
        case .failed:
            print(msg: "播放器狀態 failed")
            print(msg: player.error)
        @unknown default:
            break
        }
    }

    func showPlayerItemStatus() {
        switch player.currentItem?.status {
        case .unknown:
            print(msg: "播放器 CurrentItem 狀態 unknow")
        case .readyToPlay:
            print(msg: "播放器 CurrentItem 狀態 readyToPlay")
        case .failed:
            print(msg: "播放器 CurrentItem 狀態 failed")
        case .none:
            print(msg: "播放器 CurrentItem is nil")
        @unknown default:
            break
        }
    }
    
    func showPlayerTimeControlStatus() {
        switch player.timeControlStatus {
        case .paused:
            print(msg: "播放器 暫停中")
        case .playing:
            print(msg: "播放器 播放中")
        case .waitingToPlayAtSpecifiedRate:
            print(msg: "播放器載入中")
            if let reason = player.reasonForWaitingToPlay {
                if reason == AVPlayer.WaitingReason.evaluatingBufferingRate {
                    print(msg: "播放器視狀況準備開始播放")
                }
                if reason == AVPlayer.WaitingReason.noItemToPlay {
                    print(msg: "沒有 item 可以播放")
                }
                if reason == AVPlayer.WaitingReason.toMinimizeStalls {
                    print(msg: "播放器等待緩衝載入中")
                }
            } else {
                print(msg: "不應該要進到這裡，如果進到這裡，就是 Apple 的問題了.")
            }
        @unknown default:
            break
        }
    }
    
    func showDuration() {
        guard let duration = player.currentItem?.duration else { return }
        if CMTIME_IS_INDEFINITE(duration) {
            print(msg: "當下 Item 總長度未知")
        } else {
            print(msg: "當下 Item 總長度: \(duration)")
            print(msg: "當下 Item 總長度: \(duration.timeInterval)")
        }
    }
    
    func showRateChange() {
        print(msg: "播放器當下的速率是: \(player.rate)")
    }
 
}
