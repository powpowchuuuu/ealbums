@testable import EAlbums
import Foundation

/// A shelf in memory that remembers what was saved.
nonisolated final class FakeShelfStorage: ShelfStorage, @unchecked Sendable {
    struct Failure: Error {}

    var stored: [ShelfEntry]
    var fails = false
    private(set) var saves = 0

    init(_ stored: [ShelfEntry] = []) {
        self.stored = stored
    }

    func load() throws -> [ShelfEntry] {
        if fails { throw Failure() }
        return stored
    }

    func save(_ entries: [ShelfEntry]) throws {
        if fails { throw Failure() }
        saves += 1
        stored = entries
    }
}
