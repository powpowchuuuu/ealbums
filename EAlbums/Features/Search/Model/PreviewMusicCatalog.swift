#if DEBUG
import Foundation

/// Made-up results with no artwork, to look at the screens without Apple Music (`-preview-catalog`).
nonisolated struct PreviewMusicCatalog: MusicCatalog {
    func search(_ term: String) async throws -> [Release] {
        try await Task.sleep(for: .milliseconds(300))
        return (1...8).map { index in
            Release(
                id: "album:\(index)",
                title: index.isMultiple(of: 2) ? "\(term.capitalized) \(index) - Single" : "\(term.capitalized) Vol. \(index)",
                artist: term.uppercased(),
                kind: index.isMultiple(of: 2) ? .single : .album,
                artworkURL: nil,
                url: nil
            )
        }
    }
}
#endif
