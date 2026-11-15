@testable import EAlbums
import Foundation
import Testing

@Suite("Shelf store")
struct ShelfStoreTests {
    @Test("loads what was saved")
    func loads() {
        let store = ShelfStore(storage: FakeShelfStorage([.sample(.sample(), day: 1)]))
        store.load()
        #expect(store.entries.map(\.id) == ["album:1"])
    }

    @Test("a shelf that cannot be read starts empty")
    func loadFails() {
        let storage = FakeShelfStorage([.sample(.sample(), day: 1)])
        storage.fails = true
        let store = ShelfStore(storage: storage)
        store.load()
        #expect(store.entries.isEmpty)
    }

    @Test("toggling adds a release with the time, then takes it off, saving each time")
    func toggles() {
        let storage = FakeShelfStorage()
        let added = Date(timeIntervalSince1970: 1000)
        let store = ShelfStore(storage: storage) { added }
        store.toggle(.sample())
        #expect(store.contains("album:1"))
        #expect(storage.stored == [ShelfEntry(release: .sample(), addedAt: added)])
        store.toggle(.sample())
        #expect(!store.contains("album:1"))
        #expect(storage.stored.isEmpty)
        #expect(storage.saves == 2)
    }

    @Test("removes by id")
    func removes() {
        let storage = FakeShelfStorage([
            .sample(.sample(id: "album:1"), day: 1),
            .sample(.sample(id: "song:2"), day: 2),
        ])
        let store = ShelfStore(storage: storage)
        store.load()
        store.remove("album:1")
        #expect(store.entries.map(\.id) == ["song:2"])
        #expect(storage.stored.map(\.id) == ["song:2"])
    }

    @Test("a failed save keeps the change and says so")
    func saveFails() {
        let storage = FakeShelfStorage()
        storage.fails = true
        let store = ShelfStore(storage: storage)
        store.toggle(.sample())
        #expect(store.contains("album:1"))
        #expect(store.saveFailed)
    }

    @Test("tells after each successful save, not after a failed one")
    func didSave() {
        let storage = FakeShelfStorage()
        var saves = 0
        let store = ShelfStore(storage: storage) { Date() } didSave: { saves += 1 }
        store.toggle(.sample())
        store.toggle(.sample())
        storage.fails = true
        store.toggle(.sample())
        #expect(saves == 2)
    }

    @Test("visible applies the query")
    func visible() {
        let store = ShelfStore(storage: FakeShelfStorage([
            .sample(.sample(id: "album:1", kind: .album), day: 1),
            .sample(.sample(id: "song:2", kind: .song), day: 2),
        ]))
        store.load()
        store.query.kind = .song
        #expect(store.visible.map(\.id) == ["song:2"])
    }
}
