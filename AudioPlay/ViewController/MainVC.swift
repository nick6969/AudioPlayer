//
//  MainVC.swift
//  AudioPlay
//
//  Created by Nick on 3/26/21.
//

import UIKit
import AVFoundation

final class MainVC: UIViewController {

    private lazy var stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(playEasyButton)
        stackView.addArrangedSubview(playInitButton)
        stackView.addArrangedSubview(playItemInitButton)
        stackView.addArrangedSubview(playTimeControlStatusButton)
        stackView.addArrangedSubview(playItemDurationButton)
        stackView.addArrangedSubview(playItemCurrentTimeButton)
        stackView.addArrangedSubview(playControlButton)
        return stackView
    }()
    
    private lazy var playEasyButton: UIButton = getButton("Play So Easy")
    private lazy var playInitButton: UIButton = getButton("Player Init")
    private lazy var playItemInitButton: UIButton = getButton("Player Item Init")
    private lazy var playTimeControlStatusButton: UIButton = getButton("Player TimeControlStatus")
    private lazy var playItemDurationButton: UIButton = getButton("Player Item Duration")
    private lazy var playItemCurrentTimeButton: UIButton = getButton("Player Item CurrentTime")
    private lazy var playControlButton: UIButton = getButton("Player Control")

    @objc
    private func didTap(_ button: UIButton) {
        let nextVC: UIViewController
        switch button {
        case playEasyButton: nextVC = PlayEasyVC()
        case playInitButton: nextVC = PlayerIntiVC()
        case playItemInitButton: nextVC = PlayItemInitVC()
        case playTimeControlStatusButton: nextVC = PlayerTimeControlStatusVC()
        case playItemDurationButton: nextVC = PlayerItemDurationVC()
        case playItemCurrentTimeButton: nextVC = PlayerItemPeriodicVC()
        case playControlButton: nextVC = PlayControlVC()
        default:
            return
        }
        navigationController?.pushViewController(nextVC, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        stackView.mLaySafe(pin: .init(top: 20, leading: 20, bottom: 20, trailing: 20))
    }
    
    private func getButton(_ title: String) -> UIButton {
        let button: UIButton = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.titleLabel?.font = .systemFont(ofSize: 30)
        button.addTarget(self, action: #selector(didTap(_:)), for: .touchUpInside)
        return button
    }

}
