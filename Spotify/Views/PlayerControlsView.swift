//
//  PlayerControlsView.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 29/05/21.
//

import Foundation
import UIKit

// Protocol: Delegate for palyer controls like next song, pause and play

protocol PlayerControlsViewDelegate: AnyObject {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView)
    func playerControlsViewDidTapPBackwardsButton(_ playerControlsView: PlayerControlsView)
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float)
    
}

// Struct: ViewModel
struct PlayerControlsViewViewModel {
    let title: String?
    let subtitle: String?
}

final class PlayerControlsView: UIView{
    // variable to check if the audio is playing or not
    private var isPlaying = true
    // create a weak variable to hold delegate
    weak var delegate: PlayerControlsViewDelegate?
    private var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    //NameLabel
    private let nameLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    // subtitleLabel
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    //Buttons:
    // 1. Backbutton
    private let backButton: UIButton = {
       let button = UIButton()
        button.tintColor = .label
        let image = UIImage(systemName: "backward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34,weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    // 2. ForwardButton
    private let nextButton: UIButton = {
        let button = UIButton()
         button.tintColor = .label
         let image = UIImage(systemName: "forward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34,weight: .regular))
         button.setImage(image, for: .normal)
         return button
    }()
    // 2. ForwardButton
    private let playPauseButton: UIButton = {
        let button = UIButton()
         button.tintColor = .label
         let image = UIImage(systemName: "pause",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34,weight: .regular))
         button.setImage(image, for: .normal)
         return button
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        //Add buttons
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(volumeSlider)
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
        
        // Add Targets through delgates
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPause), for: .touchUpInside)
        // Add target for slider
        volumeSlider.addTarget(self, action: #selector(didSlideSlider), for: .valueChanged)
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //Obj C functions
    @objc private func didTapBack(){
        delegate?.playerControlsViewDidTapPBackwardsButton(self)
    }
    @objc private func didTapNext(){
        delegate?.playerControlsViewDidTapForwardButton(self)
    }
    @objc private func didTapPlayPause(){
        self.isPlaying = !isPlaying
        delegate?.playerControlsViewDidTapForwardButton(self)
        let pause = UIImage(systemName: "pause",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34,weight: .regular))
        let play = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34,weight: .regular))
        //Update the icon according to playing status
        playPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }
    @objc private func didSlideSlider(_ slider: UISlider){
        let value = slider.value
        delegate?.playerControlsView(self, didSlideSlider: value)
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        //NameLabel
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom+10, width: width, height: 50)
        volumeSlider.frame = CGRect(x: 10, y: subtitleLabel.bottom+20, width: width-20, height: 44)
        //Constant buttonSize
        let buttonSize: CGFloat = 60
        playPauseButton.frame = CGRect(x: (width - buttonSize)/2, y: volumeSlider.bottom + 30, width: buttonSize, height: buttonSize)
        backButton.frame = CGRect(x: playPauseButton.left-80-buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        nextButton.frame = CGRect(x: playPauseButton.right+80, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        
    }
    
    func configure(with ViewModel: PlayerControlsViewViewModel){
        nameLabel.text = ViewModel.title
        subtitleLabel.text = ViewModel.subtitle
    }
    
}
