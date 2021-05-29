//
//  PlayerViewController.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 04/04/21.
//

import UIKit
import SDWebImage

// Protocol: PlayerViewControllerDelegate
protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
}
class PlayerViewController: UIViewController {

    // Create a weak variable to hold playerDataSource
    weak var dataSource: PlayerDataSource?
    // Create a weak variable to hold PlayerViewControllerDelgate
    weak var delegate: PlayerViewControllerDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .systemGreen
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        //Configure Buttons
        configureBarButtons()
        configure()
    }
    
    //ViewDidLayoutSubViews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //Add frame to imageView
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        // ControlsView
        controlsView.frame = CGRect(
            x: 10,
            y: imageView.bottom+10,
            width: view.width-20,
            height: view.height-imageView.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-15
        )
    }
    
    // Configure Buttons
    private func configureBarButtons(){
        //LeftBar Button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapClose)
        )
        //RightBar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapAction)
        )
    }
    // Configure
    private func configure(){
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        controlsView.configure(
            with: PlayerControlsViewViewModel(
                title: dataSource?.songName,
                subtitle: dataSource?.subtitle)
        )
    }
    // Create an @obj c selector function
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func didTapAction(){
        
    }
    func refreshUI(){
        configure()
    }
}

// extend PlayerViewController to add delegate for PlayerControlsView

extension PlayerViewController: PlayerControlsViewDelegate{
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
    
    func playerControlsViewDidTapPBackwardsButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        //TODO
        delegate?.didTapForward()
    }
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        //TODO
        delegate?.didTapBackward()
    }
}
