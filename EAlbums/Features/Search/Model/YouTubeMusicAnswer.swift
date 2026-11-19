import Foundation

/// Reads the releases out of a YouTube Music search answer. Each result is a "musicResponsiveListItemRenderer": the
/// title in its first column, then "Album • JENNIE • 2025" for an album or "JENNIE • Ruby • 3:01" for a song.
/// The results are looked for wherever they sit in the answer, so a moved shelf does not lose them.
nonisolated enum YouTubeMusicAnswer {
    private static let separator = " • "
    private static let artworkSide = 600

    /// The albums, EPs, singles and songs in the answer, in its order, each once.
    static func releases(from data: Data) throws -> [Release] {
        var seen = Set<Release.ID>()
        return items(in: try JSONSerialization.jsonObject(with: data))
            .compactMap(release(from:))
            .filter { seen.insert($0.id).inserted }
    }

    private static func items(in object: Any) -> [[String: Any]] {
        if let list = object as? [Any] { return list.flatMap(items(in:)) }
        guard let fields = object as? [String: Any] else { return [] }
        if let item = fields["musicResponsiveListItemRenderer"] as? [String: Any] { return [item] }
        return fields.values.flatMap(items(in:))
    }

    private static func release(from item: [String: Any]) -> Release? {
        let columns = (item["flexColumns"] as? [Any] ?? []).map {
            text(value(in: $0, at: "musicResponsiveListItemFlexColumnRenderer", "text"))
        }
        guard columns.count >= 2, !columns[0].isEmpty else { return nil }
        let details = columns[1].components(separatedBy: separator)
        let artwork = artwork(of: item)
        if let video = value(in: item, at: "playlistItemData", "videoId") as? String {
            let page = URL(string: "https://music.youtube.com/watch?v=\(video)")
            return Release(
                id: "song:\(YouTubeMusicCatalog.idMark):\(video)", title: columns[0], artist: details[0],
                kind: .song, artworkURL: artwork, url: page
            )
        }
        let browse = value(in: item, at: "navigationEndpoint", "browseEndpoint")
        let pageType = value(in: browse, at: "browseEndpointContextSupportedConfigs",
                             "browseEndpointContextMusicConfig", "pageType") as? String
        guard pageType == "MUSIC_PAGE_TYPE_ALBUM", let album = value(in: browse, at: "browseId") as? String,
              details.count >= 2 else { return nil }
        return Release(
            id: "album:\(YouTubeMusicCatalog.idMark):\(album)", title: columns[0], artist: details[1],
            kind: kind(details[0]), artworkURL: artwork, url: page(album: album, playlist: playlist(of: item))
        )
    }

    /// "Single", "EP", anything else is an album.
    private static func kind(_ word: String) -> ReleaseKind {
        switch word {
        case "Single": .single
        case "EP": .ep
        default: .album
        }
    }

    /// The album's playlist link, which the YouTube Music app opens on the album; its browse page otherwise.
    private static func page(album: String, playlist: String?) -> URL? {
        if let playlist { return URL(string: "https://music.youtube.com/playlist?list=\(playlist)") }
        return URL(string: "https://music.youtube.com/browse/\(album)")
    }

    private static func playlist(of item: [String: Any]) -> String? {
        value(in: item, at: "overlay", "musicItemThumbnailOverlayRenderer", "content", "musicPlayButtonRenderer",
              "playNavigationEndpoint", "watchPlaylistEndpoint", "playlistId") as? String
    }

    /// The largest thumbnail, asked at 600 points: Google's image links carry their size as "=w120-h120".
    private static func artwork(of item: [String: Any]) -> URL? {
        let thumbnails = value(in: item, at: "thumbnail", "musicThumbnailRenderer", "thumbnail", "thumbnails")
        guard let last = (thumbnails as? [Any])?.last, let link = value(in: last, at: "url") as? String else {
            return nil
        }
        let side = "=w\(artworkSide)-h\(artworkSide)"
        return URL(string: link.replacing(/=w\d+-h\d+/, with: side))
    }

    /// The runs of a text, joined.
    private static func text(_ object: Any?) -> String {
        let runs = value(in: object, at: "runs") as? [Any] ?? []
        return runs.compactMap { value(in: $0, at: "text") as? String }.joined()
    }

    private static func value(in object: Any?, at path: String...) -> Any? {
        path.reduce(object) { ($0 as? [String: Any])?[$1] }
    }
}
