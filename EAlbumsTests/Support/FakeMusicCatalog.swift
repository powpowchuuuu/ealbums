@testable import EAlbums
import Foundation

/// A catalog with canned answers that records the words it was asked.
actor FakeMusicCatalog: MusicCatalog {
    struct Offline: Error, LocalizedError {
        var errorDescription: String? { "Offline" }
    }

    var answer: Result<[Release], any Error>
    private(set) var terms: [String] = []

    init(_ answer: Result<[Release], any Error> = .success([])) {
        self.answer = answer
    }

    func search(_ term: String) throws -> [Release] {
        terms.append(term)
        return try answer.get()
    }
}
