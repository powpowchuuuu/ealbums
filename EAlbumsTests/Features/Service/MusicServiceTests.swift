@testable import EAlbums
import Foundation
import Testing

@Suite("Music service")
struct MusicServiceTests {
    @Test("Apple Music until the user picks another")
    func defaultChoice() throws {
        let defaults = try #require(UserDefaults(suiteName: "test.\(UUID())"))
        #expect(MusicService.saved(in: defaults) == .appleMusic)
        defaults.set("spotify", forKey: MusicService.defaultsKey)
        #expect(MusicService.saved(in: defaults) == .appleMusic)
    }

    @Test("the choice is saved", arguments: MusicService.allCases)
    func saved(_ service: MusicService) throws {
        let defaults = try #require(UserDefaults(suiteName: "test.\(UUID())"))
        service.save(in: defaults)
        #expect(MusicService.saved(in: defaults) == service)
    }

    @Test("a release knows the service it was found in", arguments: [
        ("album:1800280826", MusicService.appleMusic),
        ("song:456", .appleMusic),
        ("album:yt:MPREb_jF8XwgufHfR", .youtubeMusic),
        ("song:yt:jaTPb7JJUt8", .youtubeMusic),
    ])
    func releaseService(id: String, service: MusicService) {
        #expect(Release.sample(id: id).service == service)
    }
}
