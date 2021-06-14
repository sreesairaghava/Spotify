//
//  LibraryViewController.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 04/04/21.
//

import UIKit

class LibraryViewController: UIViewController {

    // Create VCs and ScrollView
    private let playlistVC = LibraryPlaylistsViewController()
    private let albumcsVC = LibraryAlbumsViewController()
    // ScrollView
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    private let toggleView = LibraryToggleView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(toggleView)
        toggleView.delegate = self
       
        view.addSubview(scrollView)
        //Set Contentsize to scrollview
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        //Add scrollview Delegate
        scrollView.delegate = self

        addChildren()
        updateBarButtons()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55,
            width: view.width,
            height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55)
        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
    }
    //functions: updateBarButtons
    private func updateBarButtons(){
        switch toggleView.state{
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    //function: didTapAdd
    @objc private func didTapAdd(){
        playlistVC.showCreatePlaylistAlert()
    }
    //function: addChildren
    private func addChildren(){
        addChild(playlistVC)
        scrollView.addSubview(playlistVC.view)
        playlistVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistVC.didMove(toParent: self)
        
        addChild(albumcsVC)
        scrollView.addSubview(albumcsVC.view)
        albumcsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumcsVC.didMove(toParent: self)

    }
}

//Extension: Extend LibraryViewController to conform to UIScrollViewDelgate
extension LibraryViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-100){
            toggleView.update(for: .album)
            updateBarButtons()
        }
        else{
            toggleView.update(for: .playlist)
            updateBarButtons()
        }
    }
}
extension LibraryViewController: LibraryToggleViewDelegate{
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }
    
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
    
}
