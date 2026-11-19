import Foundation

nonisolated enum CatalogError: Error, Equatable, LocalizedError {
    /// The user has not allowed EAlbums to use Apple Music.
    case notAuthorized
    /// Apple gave no developer token: MusicKit is not enabled for the app's identifier.
    case musicKitDisabled

    var errorDescription: String? {
        switch self {
        case .notAuthorized: "Apple Music access is not allowed."
        case .musicKitDisabled: "MusicKit isn't enabled for this app's identifier on the Apple Developer site yet."
        }
    }
}

/// A music catalog, searched by words.
nonisolated protocol MusicCatalog: Sendable {
    /// Albums, EPs and singles first, then songs.
    func search(_ term: String) async throws -> [Release]
}
