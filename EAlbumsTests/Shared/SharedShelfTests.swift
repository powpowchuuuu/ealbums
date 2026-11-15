@testable import EAlbums
import Testing

@Suite("Shared shelf")
struct SharedShelfTests {
    @Test("the App Group is named after the app")
    func group() {
        #expect(SharedShelf.groupIdentifier(bundleID: "com.example.EAlbums") == "group.com.example.EAlbums")
    }

    @Test("the widgets find the same group as the app")
    func widgetGroup() {
        #expect(SharedShelf.groupIdentifier(bundleID: "com.example.EAlbums.Widgets") == "group.com.example.EAlbums")
    }
}
