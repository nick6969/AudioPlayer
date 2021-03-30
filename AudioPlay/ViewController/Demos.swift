//
//  PlayerIntiVC.swift
//  AudioPlay
//
//  Created by Nick on 3/30/21.
//

import UIKit
import AVFoundation

class PlayEasyVC: DemoVC {
    
    private lazy var demoButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle("DEMO", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(didTap(demo:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(demoButton)
        demoButton.mLayChainCenterXY().mLayChain(size: CGSize(width: 120, height: 80))
    }

    @objc func didTap(demo button: UIButton) {
        do {
            try setupPlay(with: TEST_M3U8_URL)
            player.play()
        } catch {
            print(msg: "Failed to set audio session category.")
            print(msg: error)
        }
    }

}

class PlayerIntiVC: PlayEasyVC {
    
    override func setupPlayer() {
        playerAddObserver(keyPath: .status)
    }
    
}

class PlayItemInitVC: PlayerIntiVC {
 
    override func setupPlayer() {
        super.setupPlayer()
        playerAddObserver(keyPath: .itemStatus)
    }
    
}

class PlayerTimeControlStatusVC: PlayItemInitVC {
    
    override func setupPlayer() {
        super.setupPlayer()
        playerAddObserver(keyPath: .timeControlStatus)
    }

}

class PlayerItemDurationVC: PlayerTimeControlStatusVC {
    
    override func setupPlayer() {
        super.setupPlayer()
        playerAddObserver(keyPath: .itemDuration)
    }
    
}

class PlayerItemPeriodicVC: PlayerItemDurationVC {
    
    override func setupPlayer() {
        super.setupPlayer()
        addPeriodicTimeObserver()
    }

}
