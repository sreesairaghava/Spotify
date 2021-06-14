//
//  AuthManager.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 04/04/21.
//

import Foundation

final class AuthManager{
    static let shared = AuthManager()
    private var refreshingToken = false
    private init(){}
    public var signInURL: URL?{
        let scopes = Constants.scopesArray.joined(separator: "%20")
        let baseURL = "https://accounts.spotify.com/authorize"
        let string =
            "\(baseURL)?response_type=code&client_id=\(Constants.clientID)&scope=\(scopes)&redirect_uri=\(Constants.redirectURI)&show_dialog=TRUE"
        return URL(string: string)
    }
    var isSignedIn: Bool{
        return accessToken != nil
    }
    private var accessToken: String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }
    private var refreshToken: String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    private var tokenExpirationDate: Date?{
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    private var shouldRefreshToken: Bool{
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    public func exchangeCodeForToken(
        code:String,
        completion: @escaping ((Bool) -> (Void))
    ){
        //Get Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "authorization_code"),
            URLQueryItem(name: "code",
                         value: code),
            URLQueryItem(name: "redirect_uri",
                         value: Constants.redirectURI)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base64")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField:"Authorization")
        let task = URLSession.shared.dataTask(with: request) { [weak self](data, _, error) in
            guard let data = data, error == nil else{
                completion(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result:result)
                completion(true)
                
            }
            catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
        
    }
    
    private var onRefreshBlocks = [(String) -> Void]()
    /// Suplies Valid token to be used with API Calls
    // New function to check with valid token
    public func withValidToken(completion:@escaping (String) -> Void){
        guard !refreshingToken else {
            //Append the completion
            onRefreshBlocks.append(completion)
            return
        }
        if shouldRefreshToken{
            //Refresh token
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success{
                    completion(token)
                }
            }
        }
        else if let token = accessToken {
            completion(token)
        }
    }
    public func refreshIfNeeded(completion: ((Bool) -> Void)?){
        guard !refreshingToken else {
            return
        }
        guard shouldRefreshToken else{
            completion?(true)
            return
        }
        guard let refreshToken = self.refreshToken else { return }
        //Refresh Token
        guard let url = URL(string: Constants.tokenAPIURL) else {
            return
        }
        
        //Making refreshingToken as true
        refreshingToken = true
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type",
                         value: "refresh_token"),
            URLQueryItem(name: "refresh_token",
                         value: refreshToken)
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        let basicToken = Constants.clientID+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base64")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)",
                         forHTTPHeaderField:"Authorization")
        let task = URLSession.shared.dataTask(with: request) { [weak self](data, _, error) in
            //Making refreshingToken as false
            self?.refreshingToken = false
            guard let data = data, error == nil else{
                completion?(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach{$0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result:result)
                completion?(true)
                
            }
            catch{
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()
    }
    private func cacheToken(result:AuthResponse){
        UserDefaults.standard.setValue(result.access_token,
                                       forKey: "access_token")
        if let refresh_token = result.refresh_token {
            UserDefaults.standard.setValue(refresh_token,
                                           forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)),
                                       forKey: "expirationDate")
    }
    
    public func signOut(completion: (Bool) -> Void){
    UserDefaults.standard.setValue(nil,forKey: "access_token")
    UserDefaults.standard.setValue(nil,forKey: "refresh_token")
    UserDefaults.standard.setValue(nil,forKey: "expirationDate")
        completion(true)
    }
    
}
