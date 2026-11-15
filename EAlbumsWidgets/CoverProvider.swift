import WidgetKit

/// One release at a time, the next one every hour, through the most recent of the shelf.
nonisolated struct CoverProvider: TimelineProvider {
    private static let hours = 6

    func placeholder(in _: Context) -> ShelfMoment {
        .placeholder(count: 1)
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (ShelfMoment) -> Void) {
        let side = side(for: context)
        Task { completion(await moments(side: side).first ?? .placeholder(count: 1)) }
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<ShelfMoment>) -> Void) {
        let side = side(for: context)
        Task {
            let moments = await moments(side: side)
            let next = Calendar.current.date(byAdding: .hour, value: Self.hours, to: .now) ?? .now
            completion(Timeline(entries: moments, policy: .after(next)))
        }
    }

    private func side(for context: Context) -> CGFloat {
        context.family == .systemLarge ? 700 : 400
    }

    private func moments(side: CGFloat) async -> [ShelfMoment] {
        let entries = (try? SharedShelf.storage().load()) ?? []
        let releases = Spotlight.releases(from: entries, count: Self.hours)
        let artwork = await ArtworkLoader.images(for: releases, side: side)
        guard !releases.isEmpty else { return [ShelfMoment(date: .now, releases: [], artwork: [:], total: 0)] }
        return (0..<Self.hours).map { hour in
            let date = Calendar.current.date(byAdding: .hour, value: hour, to: .now) ?? .now
            let shown = Spotlight.releases(from: entries, count: 1, offset: hour)
            return ShelfMoment(date: date, releases: shown, artwork: artwork, total: entries.count)
        }
    }
}
