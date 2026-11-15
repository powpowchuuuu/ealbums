import Foundation

/// The composition root: the real services, or the preview ones on demand in Debug.
enum AppConfiguration {
    static func catalog() -> any MusicCatalog {
        #if DEBUG
        // `-preview-catalog` on launch: made-up results instead of Apple Music, for screenshots.
        if ProcessInfo.processInfo.arguments.contains("-preview-catalog") { return PreviewMusicCatalog() }
        #endif
        return AppleMusicCatalog()
    }

    static func shelf() -> ShelfStore {
        let store = ShelfStore(storage: FileShelfStorage.app)
        store.load()
        return store
    }
}
