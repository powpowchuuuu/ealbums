import Foundation

/// The YouTube Music catalog: albums, EPs and singles, then songs, each opening on its own YouTube Music page.
///
/// YouTube Music has no public search API, so this asks the one its website uses (music.youtube.com/youtubei), with no
/// key and no account. Google may change it without notice; the search then fails with a message, and the releases
/// already kept still open.
nonisolated struct YouTubeMusicCatalog: MusicCatalog {
    /// What marks a YouTube Music id: "album:yt:MPREb_…", "song:yt:<video id>".
    static let idMark = "yt"

    var region = Locale.current.region?.identifier ?? "US"
    var session = URLSession.shared

    func search(_ term: String) async throws -> [Release] {
        async let albums = releases(term, filter: .albums)
        async let songs = releases(term, filter: .songs)
        return try await albums + songs
    }

    private func releases(_ term: String, filter: Filter) async throws -> [Release] {
        guard let request = Self.request(term: term, filter: filter, region: region) else { throw URLError(.badURL) }
        let (data, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try YouTubeMusicAnswer.releases(from: data)
    }
}

nonisolated extension YouTubeMusicCatalog {
    /// The search tabs of YouTube Music, as the website asks for them.
    enum Filter: String, Sendable {
        case albums = "EgWKAQIYAWoMEA4QChADEAQQCRAF"
        case songs = "EgWKAQIIAWoMEA4QChADEAQQCRAF"
    }

    /// The website's search request, in English so the kinds ("Album", "Single", "EP") read the same everywhere.
    static func request(term: String, filter: Filter, region: String) -> URLRequest? {
        guard let endpoint = URL(string: "https://music.youtube.com/youtubei/v1/search?prettyPrint=false") else {
            return nil
        }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("https://music.youtube.com", forHTTPHeaderField: "Origin")
        let client = SearchClient(clientName: "WEB_REMIX", clientVersion: "1.20251110.01.00", hl: "en", gl: region)
        let body = SearchBody(context: SearchContext(client: client), query: term, params: filter.rawValue)
        request.httpBody = try? JSONEncoder().encode(body)
        return request
    }
}

/// The body of a search request: who asks (the website), the words, and the tab.
nonisolated private struct SearchBody: Encodable {
    let context: SearchContext
    let query: String
    let params: String
}

nonisolated private struct SearchContext: Encodable {
    let client: SearchClient
}

nonisolated private struct SearchClient: Encodable {
    let clientName: String
    let clientVersion: String
    let hl: String
    let gl: String
}
