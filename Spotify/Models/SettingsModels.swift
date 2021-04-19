//
//  SettingsModels.swift
//  Spotify
//
//  Created by Sree Sai Raghava Dandu on 18/04/21.
//

import Foundation

struct Section {
    let title: String
    let options: [Option]
}

struct Option {
    let title: String
    let handler: () -> Void
}
