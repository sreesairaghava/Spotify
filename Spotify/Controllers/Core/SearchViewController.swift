//
//  SearchViewController.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 04/04/21.
//

import UIKit
import SafariServices
class SearchViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    // Create a SearchController
    let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: SearchResultsViewController())
        vc.searchBar.placeholder = "Songs, Artists, Albums, Podcasts"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    //Defining a collection for SearchViewController
    private let collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ -> NSCollectionLayoutSection? in
            // Have Item
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)))
            //Add padding to items
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 2,
                leading: 7,
                bottom: 2,
                trailing: 7 )
            // Group
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(150)),
                subitem: item,
                count: 2)
            //Adding padding to group
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 10,
                leading: 0,
                bottom: 10,
                trailing: 0)
            //Section
            return NSCollectionLayoutSection(group: group)
        }))
    
    // Create an array of categories
    private var categories = [Category]()
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        //ADD SearchResultsUpdater to searchController
        searchController.searchResultsUpdater = self
        //Add delegate
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        view.addSubview(collectionView)
        collectionView.register( CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        
        //Get the categories:
        APICaller.shared.getCategories { [weak self] result in
            DispatchQueue.main.async {
                switch result{
                case .success(let categories):
                    self?.categories = categories
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }

            }
        }
    }
    //viewDidLayoutSubViews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    //Add method: searchButtonClicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard  let resultsController = searchController.searchResultsController as? SearchResultsViewController,
               let query = searchBar.text,
               !query.trimmingCharacters(in: .whitespaces).isEmpty
               else {
            return
        }
        // Add delegate
        resultsController.delegate = self
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result{
                case .success(let results):
                    resultsController.update(with: results)
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    func updateSearchResults(for searchController: UISearchController) {

    }
    
}

// Extend SearchViewController for SearchResultViewControllerDelegate
extension SearchViewController: SearchResultViewControllerDelegate{
    func didTapResult(_ result: SearchResult) {
        switch result {
        case .artist(let model):
            guard let url = URL(string: model.external_urls["spotify"] ?? "") else {
                return
            }
            let vc = SFSafariViewController(url: url)
            //Present this VC
            present(vc,animated: true)
        case .album(let model):
            let vc = AlbumViewController(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
           navigationController?.pushViewController(vc, animated: true)
        case .track(let model):
            PlaybackPresenter.shared.startPlayback(from: self, track: model)
        case .playlist(let model):
            let vc = PlaylistViewController(playlist: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}

//Extension for SearchView Controller
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {return UICollectionViewCell()}
        let category = categories[indexPath.row]
        cell.configure(with: CategoryCollectionViewCellViewModel(title: category.name,
                                                                 artworkURL: URL(string: category.icons.first?.url ?? "")))
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let category = categories[indexPath.row]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
