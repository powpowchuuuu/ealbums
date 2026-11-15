@testable import EAlbums
import Testing

@Suite("Spotlight")
struct SpotlightTests {
    private let entries: [ShelfEntry] = (1...4).map { day in
        .sample(.sample(id: "album:\(day)"), day: day)
    }

    @Test("the most recently added first, at most the count asked")
    func recentFirst() {
        #expect(Spotlight.releases(from: entries, count: 3).map(\.id) == ["album:4", "album:3", "album:2"])
    }

    @Test("never more than the shelf holds")
    func fewerThanAsked() {
        #expect(Spotlight.releases(from: entries, count: 9).count == 4)
    }

    @Test("an offset steps through the shelf and wraps round")
    func offset() {
        #expect(Spotlight.releases(from: entries, count: 1, offset: 1).map(\.id) == ["album:3"])
        #expect(Spotlight.releases(from: entries, count: 2, offset: 7).map(\.id) == ["album:1", "album:4"])
    }

    @Test("an empty shelf shows nothing")
    func empty() {
        #expect(Spotlight.releases(from: [], count: 3, offset: 2).isEmpty)
    }
}
