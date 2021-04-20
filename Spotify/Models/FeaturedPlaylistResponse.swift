//
//  FeaturedPlaylistResponse.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 20/04/21.
//

import Foundation

struct FeaturedPlaylistResponse: Codable {
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable {
    let items: [Playlists]
}


struct User: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
