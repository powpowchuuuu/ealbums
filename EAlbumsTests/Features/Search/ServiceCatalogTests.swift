@testable import EAlbums
import Testing

@Suite("Service catalog")
struct ServiceCatalogTests {
    private let apple = FakeMusicCatalog(.success([.sample(id: "album:apple")]))
    private let youtube = FakeMusicCatalog(.success([.sample(id: "album:youtube")]))

    @Test("searches the catalog of the service chosen", arguments: [
        (MusicService.appleMusic, "album:apple"),
        (MusicService.youtubeMusic, "album:youtube"),
    ])
    func routes(service: MusicService, id: String) async throws {
        let catalog = ServiceCatalog(appleMusic: apple, youtubeMusic: youtube) { service }
        #expect(try await catalog.search("nova").map(\.id) == [id])
    }
}
