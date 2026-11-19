import Foundation

/// Searches the catalog of the service chosen at the moment of the search.
nonisolated struct ServiceCatalog: MusicCatalog {
    let appleMusic: any MusicCatalog
    let youtubeMusic: any MusicCatalog
    let service: @Sendable () -> MusicService

    func search(_ term: String) async throws -> [Release] {
        let catalog = switch service() {
        case .appleMusic: appleMusic
        case .youtubeMusic: youtubeMusic
        }
        return try await catalog.search(term)
    }
}
