@testable import EAlbums
import Testing

@Suite("Catalog search store")
struct CatalogSearchStoreTests {
    @Test("searches the trimmed words and shows the results")
    func results() async {
        let catalog = FakeMusicCatalog(.success([.sample()]))
        let store = CatalogSearchStore(catalog: catalog)
        store.term = "  nova "
        await store.search()
        #expect(store.phase == .results([.sample()]))
        #expect(await catalog.terms == ["nova"])
    }

    @Test("empty words do not search")
    func emptyTerm() async {
        let catalog = FakeMusicCatalog(.success([.sample()]))
        let store = CatalogSearchStore(catalog: catalog)
        store.term = "   "
        await store.search()
        #expect(store.phase == .idle)
        #expect(await catalog.terms.isEmpty)
    }

    @Test("nothing found")
    func noResults() async {
        let store = CatalogSearchStore(catalog: FakeMusicCatalog(.success([])))
        store.term = "zzzz"
        await store.search()
        #expect(store.phase == .noResults)
    }

    @Test("Apple Music not allowed")
    func notAuthorized() async {
        let store = CatalogSearchStore(catalog: FakeMusicCatalog(.failure(CatalogError.notAuthorized)))
        store.term = "nova"
        await store.search()
        #expect(store.phase == .notAuthorized)
    }

    @Test("a failed search says why")
    func fails() async {
        let store = CatalogSearchStore(catalog: FakeMusicCatalog(.failure(FakeMusicCatalog.Offline())))
        store.term = "nova"
        await store.search()
        #expect(store.phase == .failed("Offline"))
    }

    @Test("reset empties the words and the results")
    func reset() async {
        let store = CatalogSearchStore(catalog: FakeMusicCatalog(.success([.sample()])))
        store.term = "nova"
        await store.search()
        store.reset()
        #expect(store.term.isEmpty)
        #expect(store.phase == .idle)
    }
}
