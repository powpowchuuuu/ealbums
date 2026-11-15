import Foundation

/// What a widget shows of the shelf.
nonisolated enum Spotlight {
    /// The most recently added releases first, `count` of them at most, starting `offset` places in and wrapping round,
    /// so a widget can step through the shelf over time.
    static func releases(from entries: [ShelfEntry], count: Int, offset: Int = 0) -> [Release] {
        let recent = entries.sorted { $0.addedAt > $1.addedAt }.map(\.release)
        guard !recent.isEmpty else { return [] }
        let start = offset % recent.count
        return (0..<min(count, recent.count)).map { recent[(start + $0) % recent.count] }
    }
}
