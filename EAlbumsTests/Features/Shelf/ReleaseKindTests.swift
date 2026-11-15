@testable import EAlbums
import Testing

@Suite("Release kind")
struct ReleaseKindTests {
    @Test("an album's kind comes from its flag and its title", arguments: [
        ("Harbor Lights", false, ReleaseKind.album),
        ("Tidal - Single", false, .single),
        ("Echo", true, .single),
        ("Paper Moons - EP", false, .ep),
        ("paper moons - ep", false, .ep),
        ("EPic Tales", false, .album),
    ])
    func ofAlbum(title: String, isSingle: Bool, kind: ReleaseKind) {
        #expect(ReleaseKind.ofAlbum(title: title, isSingle: isSingle) == kind)
    }
}
