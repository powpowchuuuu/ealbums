import Foundation

nonisolated enum ShelfOrder: String, CaseIterable, Hashable, Sendable {
    case recent, title, artist

    var label: String {
        switch self {
        case .recent: "Recently Added"
        case .title: "Title"
        case .artist: "Artist"
        }
    }
}

/// What the shelf shows: a search on title and artist, one kind or all, in an order.
nonisolated struct ShelfQuery: Hashable, Sendable {
    var text = ""
    var kind: ReleaseKind?
    var order = ShelfOrder.recent

    func apply(to entries: [ShelfEntry]) -> [ShelfEntry] {
        let words = text.trimmingCharacters(in: .whitespaces)
        return entries
            .filter { kind == nil || $0.release.kind == kind }
            .filter { words.isEmpty || $0.release.matches(words) }
            .sorted(by: comesFirst)
    }

    private func comesFirst(_ lhs: ShelfEntry, _ rhs: ShelfEntry) -> Bool {
        let (left, right) = (lhs.release, rhs.release)
        switch order {
        case .recent:
            return lhs.addedAt > rhs.addedAt

        case .title:
            return Self.isBefore([left.title, left.artist], [right.title, right.artist])

        case .artist:
            return Self.isBefore([left.artist, left.title], [right.artist, right.title])
        }
    }

    /// Compares the strings in turn as Finder does: the first difference decides.
    private static func isBefore(_ lhs: [String], _ rhs: [String]) -> Bool {
        for (left, right) in zip(lhs, rhs) {
            let result = left.localizedStandardCompare(right)
            if result != .orderedSame { return result == .orderedAscending }
        }
        return false
    }
}

nonisolated private extension Release {
    /// Whether the title or the artist contains the words, whatever the case and accents.
    func matches(_ words: String) -> Bool {
        title.localizedStandardContains(words) || artist.localizedStandardContains(words)
    }
}
