//
//  LibraryAlbumsResponse.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 05/06/21.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}
