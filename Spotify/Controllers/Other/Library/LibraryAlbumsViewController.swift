//
//  LibraryAlbumsViewController.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 02/06/21.
//

import UIKit

class LibraryAlbumsViewController: UIViewController {

    var albums = [Album]()
    // ActionLabelView for Adding Albums
    private let noAlbumsView = ActionLabelView()
    //Create a tableview to hold albums
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            SearchResultSubtitleTableViewCell.self,
            forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        //Hide tableview by default
        tableView.isHidden = true
        return tableView
    }()
    
    private var observer: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        //TODO:Function: setupNoAlbumsView
        setUpNoAlbumsView()
        //TODO:Function: fetchData
        fetchAlbumData()
        observer = NotificationCenter.default.addObserver(forName: .albumsSavedNotification,
                                                          object: nil, queue: .main, using: { [weak self] _ in
                                                            self?.fetchAlbumData()
                                                          })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.width-150)/2, y: (view.height-150)/2, width: 150, height: 150)
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
    }
    //Function: updateUI
    private func updateUI(){
        if albums.isEmpty{
            //ShowLabel
            noAlbumsView.isHidden = false
            //Hide tableView if noAlbumsView is showing
            tableView.isHidden = true
        }
        else{
            tableView.reloadData()
            tableView.isHidden = false
            noAlbumsView.isHidden = true
        }
    }
    //Function: setupNoAlbumsView
    private func setUpNoAlbumsView(){
        view.addSubview(noAlbumsView)
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(
                                text: "You don't have any albums saved", actionTitle: "Browse"))
    }
    // Function: fetchAlbumData
    private func fetchAlbumData(){
        albums.removeAll()
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let albums):
                    self?.albums = albums
                    print(albums.count)
                    self?.updateUI()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

}
//TableViewDelegate
extension LibraryAlbumsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SearchResultSubtitleTableViewCell.identifier,
                for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(
                        title: album.name,
                        subtitle: album.artists.first?.name ?? "",
                        imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
//ActionViewDelegate
extension LibraryAlbumsViewController: ActionLabelViewDelegate{
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
    
    
}
