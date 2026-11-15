import Foundation

/// The link a widget opens: EAlbums's own scheme carrying the Apple Music page, which the app passes on to Music.
/// Widgets can only open their own app, so the Music link travels inside this one.
nonisolated enum MusicLink {
    static let scheme = "ealbums"

    /// "ealbums://open?music=<the Apple Music link>", or nil without one.
    static func widgetURL(for musicURL: URL?) -> URL? {
        guard let musicURL else { return nil }
        var link = URLComponents()
        link.scheme = scheme
        link.host = "open"
        link.queryItems = [URLQueryItem(name: "music", value: musicURL.absoluteString)]
        return link.url
    }

    /// The Apple Music link inside a widget link; nil for anything else.
    static func musicURL(from url: URL) -> URL? {
        guard url.scheme == scheme,
              let value = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first(where: { $0.name == "music" })?.value,
              let music = URL(string: value), music.scheme == "https" else { return nil }
        return music
    }
}
