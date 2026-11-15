@testable import EAlbums
import Foundation
import Testing

@Suite("Music link")
struct MusicLinkTests {
    private let album = URL(string: "https://music.apple.com/fr/album/some-album/123?i=456&l=en")

    @Test("a widget link carries the Apple Music link and gives it back whole")
    func roundTrip() throws {
        let link = try #require(MusicLink.widgetURL(for: album))
        #expect(link.scheme == "ealbums")
        #expect(MusicLink.musicURL(from: link) == album)
    }

    @Test("no Apple Music link, no widget link")
    func none() {
        #expect(MusicLink.widgetURL(for: nil) == nil)
    }

    @Test("other links are not Music links", arguments: [
        "https://music.apple.com/fr/album/x/1",
        "ealbums://open",
        "ealbums://open?music=not%20a%20url",
        "other://open?music=https%3A%2F%2Fmusic.apple.com",
    ])
    func others(_ text: String) throws {
        #expect(MusicLink.musicURL(from: try #require(URL(string: text))) == nil)
    }
}
