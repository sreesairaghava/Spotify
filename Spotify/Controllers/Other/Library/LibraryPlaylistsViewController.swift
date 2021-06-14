//
//  LibraryPlaylistsViewController.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 02/06/21.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
    private let noPlaylistsView = ActionLabelView()
    var playlists = [Playlist]()
    // CompletionHandler to pass the playlist back to caller from actionSheet
    public var selectionHandler: ((Playlist) -> Void)?
    // Create a tableview to hold playlists
    private let tableView: UITableView = {
        let tableView = UITableView()
        //Register tableview to show custom table view cell
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        setUpNoPlaylistsView()
        fetchPlaylistsData()
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    @objc func didTapClose(){
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistsView.center = view.center
        tableView.frame = view.bounds
    }
    //Function: updateUI
    private func updateUI(){
        if playlists.isEmpty {
            // Show label
            noPlaylistsView.isHidden = false
            tableView.isHidden = true
        }
        else{
            //Show table of playslist
            tableView.reloadData()
            tableView.isHidden = false
            noPlaylistsView.isHidden = true
            print("You have palylists")
        }
    }
    
    private func setUpNoPlaylistsView(){
        view.addSubview(noPlaylistsView)
        noPlaylistsView.delegate = self
        noPlaylistsView.configure(
            with: ActionLabelViewViewModel(
                text: "You don't have any playlists yet",
                actionTitle: "Create"
            )
        )
    }
    private func fetchPlaylistsData(){
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    public func showCreatePlaylistAlert(){
        //Show creationView
        let alert = UIAlertController(
            title: "New Playlist",
            message: "Enter playlist name",
            preferredStyle: .alert)
        alert.addTextField { textFeild in
            textFeild.placeholder = "Playlist..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            APICaller.shared.createPlaylist(with: text) { [weak self] success in
                if success{
                    HapticsManager.shared.vibrate(for: .success)
                    self?.fetchPlaylistsData()
                }
                else{
                    HapticsManager.shared.vibrate(for: .error)
                    print("Failed to create playlist")
                }
            }
        }))
        present(alert, animated: true)
    }
}

// Extend LibraryPlaylistsViewControllers to conform to delegate
extension LibraryPlaylistsViewController: ActionLabelViewDelegate{
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}

// Extension: To conform to tableview delegate and datasource
extension LibraryPlaylistsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(
            with: SearchResultSubtitleTableViewCellViewModel(
                title: playlist.name,
                subtitle: playlist.owner.display_name,
                imageURL: URL(string: playlist.images.first?.url ?? "")
            )
        )
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let playlist = playlists[indexPath.row]
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true, completion: nil)
            return
        }
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        //Make isOwner true as Playlist created by Current User here
        vc.isOnwer = true
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
