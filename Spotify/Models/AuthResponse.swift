//
//  AuthResponse.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 11/04/21.
//

import Foundation

struct AuthResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
