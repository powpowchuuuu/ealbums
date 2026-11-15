@testable import EAlbums
import Foundation
import Testing

@Suite("File shelf storage")
struct FileShelfStorageTests {
    private let folder = URL.temporaryDirectory.appending(path: "Shelf Tests \(UUID().uuidString)")

    @Test("reads back what it saved, in a folder with a space in its name")
    func roundTrip() throws {
        let storage = FileShelfStorage(fileURL: folder.appending(path: "shelf.json"))
        let entries = [ShelfEntry.sample(.sample(), day: 2)]
        try storage.save(entries)
        #expect(try storage.load() == entries)
        try FileManager.default.removeItem(at: folder)
    }

    @Test("no file yet is an empty shelf")
    func noFile() throws {
        #expect(try FileShelfStorage(fileURL: folder.appending(path: "shelf.json")).load().isEmpty)
    }
}
