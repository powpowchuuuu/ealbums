import Foundation

/// What a release is on Apple Music. Singles and EPs are albums there; a song stands alone.
nonisolated enum ReleaseKind: String, Codable, Hashable, Sendable, CaseIterable {
    case album, ep, single, song

    /// The kind of an Apple Music album: a single when flagged or titled " - Single", an EP when titled " - EP".
    static func ofAlbum(title: String, isSingle: Bool) -> Self {
        let lowered = title.lowercased()
        if isSingle || lowered.hasSuffix(" - single") { return .single }
        if lowered.hasSuffix(" - ep") { return .ep }
        return .album
    }

    var label: String {
        switch self {
        case .album: "Albums"
        case .ep: "EPs"
        case .single: "Singles"
        case .song: "Songs"
        }
    }
}

/// An album, EP, single or song from the Apple Music catalog.
nonisolated struct Release: Identifiable, Hashable, Codable, Sendable {
    /// Unique across kinds: "album:1234" or "song:5678".
    let id: String
    let title: String
    let artist: String
    let kind: ReleaseKind
    let artworkURL: URL?
    /// Its page in Apple Music.
    let url: URL?
}

/// A release kept on the shelf, with when it was added.
nonisolated struct ShelfEntry: Identifiable, Hashable, Codable, Sendable {
    let release: Release
    let addedAt: Date

    var id: String { release.id }
}
