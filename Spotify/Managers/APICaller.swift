//
//  APICaller.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 04/04/21.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    private init(){}
    // Struct: Constants
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    // Enum: API Errors
    enum APIError: Error {
        case failedToGetData
    }
    //MARK: - Albums
    public func getAlbumDetails(for album: Album, completion: @escaping (Result<AlbumDetailsResponse, Error>) -> Void) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/albums/" + album.id),
            type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    print("Checking Error at API Caller Level: \(error)")
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Playlists
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping (Result<PlaylistDetailsResponse,Error>)-> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    //Functions: getCurrentPlaylist, createPlaylist, addTrackToPlaylist, removeTrackFromPlaylist
    public func getCurrentUserPlaylists(completion: @escaping (Result<[Playlist],Error>) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/playlists/?limit=50"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(LibraryPlaylistsResponse.self, from: data)
                    completion(.success(result.items))
                }
                catch{
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    public func createPlaylist(
        with name: String,
        completion: @escaping (Bool) -> Void){
        getCurrentUserProfile { [weak self] result in
            switch result{
            case .success(let profile):
                let urlString = Constants.baseAPIURL + "/users/\(profile.id)/playlists"
                self?.createRequest(
                    with: URL(string: urlString),
                    type: .POST,
                    completion: { baseRequest in
                        var request = baseRequest
                        let json = ["name": name]
                        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                        let task = URLSession.shared.dataTask(with: request) { data, _, error in
                            guard let data = data, error == nil else{
                                return
                            }
                            do {
                                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                                if let response = result as? [String: Any], response["id"] as? String != nil {
                                    print("Created")
                                   completion(true)
                                }
                                else {
                                    print("Failed to create")
                                    completion(false)
                                }
                            }
                            catch{
                                print(error.localizedDescription)
                                completion(false)
                            }
                        }
                        task.resume()
                    })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    public func addTrackToPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void
    ) {
        createRequest(with: URL(
                        string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
                      type: .POST) { baseRequest in
            var request = baseRequest
            let json = [
                "uris" : [
                    "spotify:track:\(track.id)"
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request){ data, _, error in
                guard let data = data, error == nil else{
                    completion(false)
                    return
                }
                do{
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil {
                        completion(true)
                    }
                    else{
                        completion(false)
                    }
                }
                catch{
                    completion(false)
                }
            }
            task.resume()
        }
    }
    public func removeTrackFromPlaylist(
        track: AudioTrack,
        playlist: Playlist,
        completion: @escaping (Bool) -> Void
    ) {
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"),
            type: .DELETE) { baseRequest in
            var request = baseRequest
            let json: [String: Any] = [
                "tracks": [
                    ["uri": "spotify:track:\(track.id)"]
                ]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(false)
                    return
                }
                do{
                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let response = result as? [String: Any],
                       response["snapshot_id"] as? String != nil{
                        completion(true)
                    }
                    else{
                        print(result)
                        completion(false)
                    }
                }
                catch{
                    completion(false)
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Albums
    public func getCurrentUserAlbums(completion: @escaping (Result<[Album],Error>) -> Void){
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/me/albums"),
            type: .GET) {
            request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                print(request)
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try
                        JSONDecoder().decode(LibraryAlbumsResponse.self, from: data)
//                        JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success(result.items.compactMap({ $0.album })))
                }
                catch{
                    completion(.failure(error))
                    print("From APICaller function: \(error)")
                }
            }
            task.resume()
        }
    }
    
    public func saveAlbum(album: Album, completion: @escaping (Bool) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums?ids=\(album.id)"),
                      type: .PUT) { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard
                      let code = (response as? HTTPURLResponse)?.statusCode,
                      error == nil else{
                    completion(false)
                    return
                }
                print(code)
                completion(code == 200)
            }
            task.resume()
        }
    }
    //MARK: - Profile
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile,Error>) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"),
                      type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                }
                catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    /// Function to return all the new releases
    public func getAllNewReleases(completion: @escaping ((Result<NewReleaseResponse,Error>)->Void)){
        // Create Request
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=50"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                //Do Catch block to get JSON data
                do{
                    let result = try JSONDecoder().decode(NewReleaseResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    ///Function to get Featured Playlists
    public func getFeaturedPlaylists(completion: @escaping ((Result<FeaturedPlaylistResponse,Error>)-> Void)){
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                //Do-Catch block to get the JSON data from API
                do{
                    let result = try JSONDecoder().decode(FeaturedPlaylistResponse.self, from: data)
                    completion(.success(result ))
                }
                catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    /// Function to Get Recommendation Genres
    public func getRecommendationGenres(completion: @escaping ((Result<RecommendationGenresResponse,Error>) -> Void)){
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(RecommendationGenresResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    /// Function to Get Recommendations
    public func getRecommendations(genres: Set<String>, completion: @escaping ((Result<RecommendationsResponse,Error>) -> Void)){
        let seeds = genres.joined(separator: ",")
        //Create Request call
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
                    completion(.success(result))
                }
                catch{
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Category
    public func getCategories(completion: @escaping (Result<[Category],Error>) -> Void){
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/browse/categories?limt=50"),
            type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(AllCategoriesResponse.self, from: data)
                    //JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    completion(.success(result.categories.items))
                    
                }
                catch{
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    public func getCategoryPlaylists(category: Category, completion: @escaping (Result<[Playlist], Error>) -> Void){
        createRequest(
            with: URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=50"),
            type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(CategoryPlaylistsResponse.self, from: data)
                    let playlists = result.playlists.items
                    completion(.success(playlists))
                }
                catch{
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Search
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        createRequest(with: URL(string:
                                    Constants.baseAPIURL + "/search?limit=15&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else{
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(SearchResultResponse.self, from: data)
                    var searchResults: [SearchResult] = []
                    searchResults.append(contentsOf: result.tracks.items.compactMap({ SearchResult.track(model: $0)}))
                    searchResults.append(contentsOf: result.albums.items.compactMap({ SearchResult.album(model: $0)}))
                    searchResults.append(contentsOf: result.artists.items.compactMap({ SearchResult.artist(model: $0)}))
                    searchResults.append(contentsOf: result.playlists.items.compactMap({ SearchResult.playlist(model: $0)}))
                    
                    completion(.success(searchResults))
                }
                catch{
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    //MARK: - Private
    //Enum: for HTTP Method
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    private func createRequest(with url: URL?,
                               type: HTTPMethod,
                               completion: @escaping (URLRequest) -> Void){
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else{
                return
            }
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)",
                             forHTTPHeaderField: "Authorization")
            //set HTTP Method from the enum
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            // Call the completion handler with request
            completion(request)
        }
    }
}
