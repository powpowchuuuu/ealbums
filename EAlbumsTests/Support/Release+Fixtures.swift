@testable import EAlbums
import Foundation

extension Release {
    static func sample(
        id: String = "album:1",
        title: String = "Tidal - Single",
        artist: String = "NOVA",
        kind: ReleaseKind = .single
    ) -> Self {
        Self(id: id, title: title, artist: artist, kind: kind, artworkURL: nil, url: nil)
    }
}

extension ShelfEntry {
    static func sample(_ release: Release, day: Int) -> Self {
        Self(release: release, addedAt: Date(timeIntervalSince1970: Double(day) * 86_400))
    }
}
