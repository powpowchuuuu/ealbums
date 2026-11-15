@testable import EAlbums
import Testing

@Suite("Shelf query")
struct ShelfQueryTests {
    private let entries: [ShelfEntry] = [
        .sample(.sample(id: "album:1", title: "Harbor Lights", artist: "NOVA", kind: .album), day: 1),
        .sample(.sample(id: "album:2", title: "Les Pêcheurs - Single", artist: "Lina Moreau", kind: .single),
                day: 3),
        .sample(.sample(id: "song:3", title: "Aurora", artist: "ÉLA", kind: .song), day: 2),
    ]

    @Test("by default the most recently added comes first")
    func recentFirst() {
        #expect(ShelfQuery().apply(to: entries).map(\.id) == ["album:2", "song:3", "album:1"])
    }

    @Test("sorts by title or by artist")
    func sorts() {
        #expect(ShelfQuery(order: .title).apply(to: entries).map(\.id) == ["song:3", "album:1", "album:2"])
        #expect(ShelfQuery(order: .artist).apply(to: entries).map(\.id) == ["song:3", "album:2", "album:1"])
    }

    @Test("searches title and artist, ignoring case and accents")
    func searches() {
        #expect(ShelfQuery(text: "pecheurs").apply(to: entries).map(\.id) == ["album:2"])
        #expect(ShelfQuery(text: "ela").apply(to: entries).map(\.id) == ["song:3"])
        #expect(ShelfQuery(text: "  ").apply(to: entries).count == 3)
    }

    @Test("keeps one kind")
    func filters() {
        #expect(ShelfQuery(kind: .single).apply(to: entries).map(\.id) == ["album:2"])
    }
}
