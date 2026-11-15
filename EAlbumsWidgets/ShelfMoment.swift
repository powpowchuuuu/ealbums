import UIKit
import WidgetKit

/// What a widget draws at one moment: the releases it shows, their artwork, and the shelf's size.
nonisolated struct ShelfMoment: TimelineEntry {
    let date: Date
    let releases: [Release]
    let artwork: [Release.ID: UIImage]
    let total: Int

    /// Made-up releases without artwork, for the widget gallery before anything loads.
    static func placeholder(count: Int) -> Self {
        let made = (1...count).map { index in
            Release(id: "album:\(index)", title: "Album \(index)", artist: "Artist", kind: .album, artworkURL: nil, url: nil)
        }
        return Self(date: .now, releases: made, artwork: [:], total: count)
    }
}

/// Downloads artwork for the widgets, shrunk to what a widget needs, all at once.
nonisolated enum ArtworkLoader {
    static func images(for releases: [Release], side: CGFloat) async -> [Release.ID: UIImage] {
        await withTaskGroup(of: (Release.ID, UIImage?).self) { group in
            for release in releases {
                group.addTask { (release.id, await image(at: release.artworkURL, side: side)) }
            }
            var images: [Release.ID: UIImage] = [:]
            for await (id, image) in group {
                images[id] = image
            }
            return images
        }
    }

    private static func image(at url: URL?, side: CGFloat) async -> UIImage? {
        guard let url, let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        return await UIImage(data: data)?.byPreparingThumbnail(ofSize: CGSize(width: side, height: side))
    }
}
