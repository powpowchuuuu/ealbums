@testable import EAlbums
import Foundation
import Testing

@Suite("Service store")
struct ServiceStoreTests {
    private let defaults = UserDefaults(suiteName: "test.\(UUID())") ?? .standard

    @Test("starts on Apple Music")
    func startsOnAppleMusic() {
        #expect(ServiceStore(defaults: defaults).service == .appleMusic)
    }

    @Test("starts on the saved choice")
    func startsOnSaved() {
        MusicService.youtubeMusic.save(in: defaults)
        #expect(ServiceStore(defaults: defaults).service == .youtubeMusic)
    }

    @Test("a new choice is kept for the next launch")
    func change() {
        ServiceStore(defaults: defaults).service = .youtubeMusic
        #expect(ServiceStore(defaults: defaults).service == .youtubeMusic)
    }
}
