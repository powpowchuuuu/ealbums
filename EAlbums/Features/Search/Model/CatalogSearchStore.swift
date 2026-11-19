import Foundation
import Observation

/// The search in the add sheet: the words typed and what the catalog answered.
@Observable
final class CatalogSearchStore {
    enum Phase: Equatable {
        case idle
        case searching
        case results([Release])
        case noResults
        case notAuthorized
        case failed(String)
    }

    var term = ""
    private(set) var phase = Phase.idle

    private let catalog: any MusicCatalog

    init(catalog: any MusicCatalog) {
        self.catalog = catalog
    }

    /// Searches the current words; an answer for words since changed is dropped.
    func search() async {
        let words = term.trimmingCharacters(in: .whitespaces)
        guard !words.isEmpty else {
            phase = .idle
            return
        }
        // Keep the last results on screen while the next ones load.
        if case .results = phase {} else { phase = .searching }
        let answer: Phase
        do {
            let releases = try await catalog.search(words)
            answer = releases.isEmpty ? .noResults : .results(releases)
        } catch CatalogError.notAuthorized {
            answer = .notAuthorized
        } catch {
            answer = .failed(error.localizedDescription)
        }
        guard words == term.trimmingCharacters(in: .whitespaces) else { return }
        phase = answer
    }

    /// Back to an empty search, for the next time the sheet opens.
    func reset() {
        term = ""
        phase = .idle
    }
}
