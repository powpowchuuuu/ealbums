import WidgetKit

/// The latest releases of the shelf, refreshed when the app changes it.
nonisolated struct ShelfProvider: TimelineProvider {
    func placeholder(in context: Context) -> ShelfMoment {
        .placeholder(count: Self.count(for: context))
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (ShelfMoment) -> Void) {
        let count = Self.count(for: context)
        Task { completion(await moment(count: count)) }
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<ShelfMoment>) -> Void) {
        let count = Self.count(for: context)
        Task {
            let moment = await moment(count: count)
            completion(Timeline(entries: [moment], policy: .never))
        }
    }

    private static func count(for context: Context) -> Int {
        context.family == .systemLarge ? 9 : 3
    }

    private func moment(count: Int) async -> ShelfMoment {
        let entries = (try? SharedShelf.storage().load()) ?? []
        let releases = Spotlight.releases(from: entries, count: count)
        let artwork = await ArtworkLoader.images(for: releases, side: 300)
        return ShelfMoment(date: .now, releases: releases, artwork: artwork, total: entries.count)
    }
}
