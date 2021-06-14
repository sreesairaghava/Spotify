//
//  LibraryToggleView.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 02/06/21.
//

import UIKit
//Protocol: Delgate
protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}
class LibraryToggleView: UIView {
    
    //Enum: State
    enum State {
        case playlist
        case album
    }
    
  // Create a var to hold state
    var state: State = .playlist
    
    //Create a weak variable to hold the delegate
    weak var delegate: LibraryToggleViewDelegate?
    
    private let playlistButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
       return button
    }()
    private let albumsButton: UIButton = {
       let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
       return button
    }()
    //Indicator view
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        //Add Targets
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
    }
    func layoutIndicator(){
        switch state {
        case .playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistButton.bottom, width: 100, height: 3)
        case .album:
            indicatorView.frame = CGRect(x: 100, y: albumsButton.bottom, width: 100, height: 3)
        }
    }
    // @Objc methods for target selectors
    @objc private func didTapPlaylists(){
        state = .playlist
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }
    @objc private func didTapAlbums(){
        state = .album
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapAlbums(self)
    }
    func update(for state: State){
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
    }

}
