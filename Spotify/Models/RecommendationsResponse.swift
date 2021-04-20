//
//  RecommendationsResponse.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 20/04/21.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
