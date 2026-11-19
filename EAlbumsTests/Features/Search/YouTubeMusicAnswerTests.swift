@testable import EAlbums
import Foundation
import Testing

@Suite("YouTube Music answer")
struct YouTubeMusicAnswerTests {
    private static func album(_ title: String, _ details: String, browse: String, playlist: String?) -> String {
        let overlay = playlist.map {
            """
            "overlay": {"musicItemThumbnailOverlayRenderer": {"content": {"musicPlayButtonRenderer": {
              "playNavigationEndpoint": {"watchPlaylistEndpoint": {"playlistId": "\($0)"}}}}}},
            """
        } ?? ""
        return """
        {"musicResponsiveListItemRenderer": {
          "thumbnail": {"musicThumbnailRenderer": {"thumbnail": {"thumbnails": [
            {"url": "https://yt3.googleusercontent.com/a=w60-h60-l90-rj"},
            {"url": "https://yt3.googleusercontent.com/a=w544-h544-l90-rj"}]}}},
          \(overlay)
          "flexColumns": [
            {"musicResponsiveListItemFlexColumnRenderer": {"text": {"runs": [{"text": "\(title)"}]}}},
            {"musicResponsiveListItemFlexColumnRenderer": {"text": {"runs": [{"text": "\(details)"}]}}}],
          "navigationEndpoint": {"browseEndpoint": {"browseId": "\(browse)",
            "browseEndpointContextSupportedConfigs": {"browseEndpointContextMusicConfig": {
              "pageType": "MUSIC_PAGE_TYPE_ALBUM"}}}}}}
        """
    }

    private static let song = """
    {"musicResponsiveListItemRenderer": {
      "thumbnail": {"musicThumbnailRenderer": {"thumbnail": {"thumbnails": [
        {"url": "https://lh3.googleusercontent.com/b=w120-h120-l90-rj"}]}}},
      "flexColumns": [
        {"musicResponsiveListItemFlexColumnRenderer": {"text": {"runs": [{"text": "Love Hangover"}]}}},
        {"musicResponsiveListItemFlexColumnRenderer": {"text": {"runs": [
          {"text": "JENNIE & Dominic Fike"}, {"text": " • "}, {"text": "Ruby"}, {"text": " • "}, {"text": "3:01"}]}}}],
      "playlistItemData": {"videoId": "jaTPb7JJUt8"}}}
    """

    private static let artist = """
    {"musicResponsiveListItemRenderer": {
      "flexColumns": [
        {"musicResponsiveListItemFlexColumnRenderer": {"text": {"runs": [{"text": "JENNIE"}]}}},
        {"musicResponsiveListItemFlexColumnRenderer": {"text": {"runs": [{"text": "Artist • 20M subscribers"}]}}}],
      "navigationEndpoint": {"browseEndpoint": {"browseId": "UCAl7xQ6q0PEgZMQD7zr4AKQ",
        "browseEndpointContextSupportedConfigs": {"browseEndpointContextMusicConfig": {
          "pageType": "MUSIC_PAGE_TYPE_ARTIST"}}}}}}
    """

    private static let items = [
        album("Ruby", "Album • JENNIE • 2025", browse: "MPREb_ruby", playlist: "OLAK5uy_ruby"),
        album("Less than a Lover", "Single • JENNIE • 2026", browse: "MPREb_less", playlist: nil),
        album("Fallen Angel", "EP • JENNIE • 2026", browse: "MPREb_angel", playlist: "OLAK5uy_angel"),
        artist,
        song,
        album("Ruby", "Album • JENNIE • 2025", browse: "MPREb_ruby", playlist: "OLAK5uy_ruby"),
    ]

    /// The items deep in the answer, where the website puts them.
    private let answer = Data("""
    {"contents": {"tabbedSearchResultsRenderer": {"tabs": [{"tabRenderer": {"content": {"sectionListRenderer": {
      "contents": [{"itemSectionRenderer": {}}, {"musicShelfRenderer": {"contents": [\(items.joined(separator: ","))]}}]
    }}}}]}}}
    """.utf8)

    private func releases() throws -> [Release] {
        let releases = try YouTubeMusicAnswer.releases(from: answer)
        try #require(releases.count == 4)
        return releases
    }

    @Test("albums, singles, EPs and songs, each once, artists left out")
    func kinds() throws {
        let releases = try releases()
        #expect(releases.map(\.title) == ["Ruby", "Less than a Lover", "Fallen Angel", "Love Hangover"])
        #expect(releases.map(\.kind) == [.album, .single, .ep, .song])
        #expect(releases.map(\.artist) == ["JENNIE", "JENNIE", "JENNIE", "JENNIE & Dominic Fike"])
    }

    @Test("YouTube Music ids, apart from Apple Music's")
    func ids() throws {
        let releases = try releases()
        #expect(releases.map(\.id) == ["album:yt:MPREb_ruby", "album:yt:MPREb_less", "album:yt:MPREb_angel",
                                       "song:yt:jaTPb7JJUt8"])
        #expect(releases.allSatisfy { $0.service == .youtubeMusic })
    }

    @Test("each opens on its YouTube Music page")
    func pages() throws {
        let pages = try releases().map(\.url)
        #expect(pages == [
            URL(string: "https://music.youtube.com/playlist?list=OLAK5uy_ruby"),
            URL(string: "https://music.youtube.com/browse/MPREb_less"),
            URL(string: "https://music.youtube.com/playlist?list=OLAK5uy_angel"),
            URL(string: "https://music.youtube.com/watch?v=jaTPb7JJUt8"),
        ])
    }

    @Test("the largest cover, at 600 points")
    func artwork() throws {
        let releases = try releases()
        #expect(releases[0].artworkURL == URL(string: "https://yt3.googleusercontent.com/a=w600-h600-l90-rj"))
        #expect(releases[3].artworkURL == URL(string: "https://lh3.googleusercontent.com/b=w600-h600-l90-rj"))
    }

    @Test("an answer without results has none")
    func empty() throws {
        #expect(try YouTubeMusicAnswer.releases(from: Data(#"{"contents": {}}"#.utf8)).isEmpty)
    }

    @Test("something that is not an answer fails")
    func garbage() {
        #expect(throws: (any Error).self) { try YouTubeMusicAnswer.releases(from: Data("nope".utf8)) }
    }

    @Test("the search asks the website's API for one tab, in English, in the user's region")
    func request() throws {
        let request = try #require(YouTubeMusicCatalog.request(term: "jennie ruby", filter: .albums, region: "FR"))
        #expect(request.httpMethod == "POST")
        #expect(request.url?.host == "music.youtube.com")
        let body = try #require(request.httpBody)
        let json = try #require(try JSONSerialization.jsonObject(with: body) as? [String: Any])
        #expect(json["query"] as? String == "jennie ruby")
        #expect(json["params"] as? String == YouTubeMusicCatalog.Filter.albums.rawValue)
        let client = (json["context"] as? [String: Any])?["client"] as? [String: Any]
        #expect(client?["hl"] as? String == "en")
        #expect(client?["gl"] as? String == "FR")
    }
}
