import Foundation
import MusicKit

/// The real Apple Music catalog, through MusicKit. Asks for access the first time.
nonisolated struct AppleMusicCatalog: MusicCatalog {
    func search(_ term: String) async throws -> [Release] {
        var status = MusicAuthorization.currentStatus
        if status == .notDetermined { status = await MusicAuthorization.request() }
        guard status == .authorized else { throw CatalogError.notAuthorized }
        var request = MusicCatalogSearchRequest(term: term, types: [Album.self, Song.self])
        request.limit = 25
        let response: MusicCatalogSearchResponse
        do {
            response = try await request.response()
        } catch is MusicTokenRequestError {
            throw CatalogError.musicKitDisabled
        }
        return response.albums.map(Release.init(album:)) + response.songs.map(Release.init(song:))
    }
}

nonisolated private extension Release {
    static let artworkSide = 600

    init(album: Album) {
        self.init(
            id: "album:\(album.id.rawValue)",
            title: album.title,
            artist: album.artistName,
            kind: .ofAlbum(title: album.title, isSingle: album.isSingle ?? false),
            artworkURL: album.artwork?.url(width: Self.artworkSide, height: Self.artworkSide),
            url: album.url
        )
    }

    init(song: Song) {
        self.init(
            id: "song:\(song.id.rawValue)",
            title: song.title,
            artist: song.artistName,
            kind: .song,
            artworkURL: song.artwork?.url(width: Self.artworkSide, height: Self.artworkSide),
            url: song.url
        )
    }
}
