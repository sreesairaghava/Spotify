//
//  NewReleasesResponse.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 19/04/21.
//

import Foundation
/// NewReleaseResponseModel: Codable
/// Contains a
struct NewReleaseResponse: Codable {
    let albums: AlbumResponse
}

struct AlbumResponse: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let id: String
    var images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}
