import Foundation

/// Where the add sheet searches, and so where the releases added from it open: Apple Music unless the user picks
/// YouTube Music in the options.
nonisolated enum MusicService: String, CaseIterable, Hashable, Sendable {
    case appleMusic, youtubeMusic

    /// Where the choice is kept.
    static let defaultsKey = "musicService"

    var name: String {
        switch self {
        case .appleMusic: "Apple Music"
        case .youtubeMusic: "YouTube Music"
        }
    }

    /// The saved choice; Apple Music when there is none.
    static func saved(in defaults: UserDefaults) -> Self {
        defaults.string(forKey: defaultsKey).flatMap(Self.init(rawValue:)) ?? .appleMusic
    }

    func save(in defaults: UserDefaults) {
        defaults.set(rawValue, forKey: Self.defaultsKey)
    }
}

nonisolated extension Release {
    /// The service the release was found in, which its link opens.
    var service: MusicService {
        id.contains(":\(YouTubeMusicCatalog.idMark):") ? .youtubeMusic : .appleMusic
    }
}
