# Spotify [Clone]

Spotify, is a popular music streaming service. Creating a clone of the Spotify using UIKit, Swift 5.3, Cocapods, Spotify official API (using WEB API mostly), SDWebImage, Firebase Analytics through cocapods. ~~More content will be updated soon. This project is under active development.~~
## Installation

If you want to clone the project, you should create a ```Constants.swift ``` file with a struct as mentioned below to use clientID, clientSecret etc, from Spotify.
You can get your client ID and secret from Spotify Developer account [here](https://developer.spotify.com/dashboard/applications)



```swift
import Foundation

struct Constants {
    static let clientID = "YOUR_CLIENT_ID"
    static let clientSecret = "YOUR_CLIENT_SECRET"
    static let tokenAPIURL = "https://accounts.spotify.com/api/token"
    static let redirectURI = "REDIRECT_URL" // Can be your own website url 
    static let scopesArray = ["user-read-private",
                               "playlist-modify-public",
                               "playlist-read-private",
                               "playlist-modify-private",
                               "user-follow-read",
                               "user-read-email"
    ]
//Add scopes to capture different user accesses
}
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
