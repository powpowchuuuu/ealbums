import Foundation

/// Where the shelf is kept between launches.
nonisolated protocol ShelfStorage: Sendable {
    func load() throws -> [ShelfEntry]
    func save(_ entries: [ShelfEntry]) throws
}

/// The shelf as a JSON file in Application Support.
nonisolated struct FileShelfStorage: ShelfStorage {
    let fileURL: URL

    /// Where the app kept the shelf before the widgets shared it.
    static let appOnly = Self(fileURL: URL.applicationSupportDirectory.appending(path: "shelf.json"))

    func load() throws -> [ShelfEntry] {
        guard FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([ShelfEntry].self, from: Data(contentsOf: fileURL))
    }

    func save(_ entries: [ShelfEntry]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let folder = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try encoder.encode(entries).write(to: fileURL, options: .atomic)
    }
}
