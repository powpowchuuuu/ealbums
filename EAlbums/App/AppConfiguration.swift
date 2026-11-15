import Foundation
import WidgetKit

/// The composition root: the real services, or the preview ones on demand in Debug.
enum AppConfiguration {
    static func catalog() -> any MusicCatalog {
        #if DEBUG
        // `-preview-catalog` on launch: made-up results instead of Apple Music, for screenshots.
        if ProcessInfo.processInfo.arguments.contains("-preview-catalog") { return PreviewMusicCatalog() }
        #endif
        return AppleMusicCatalog()
    }

    /// The shelf in the App Group the widgets read, which reload after every change.
    static func shelf(widgets: WidgetCenter = WidgetCenter.shared) -> ShelfStore {
        let storage = SharedShelf.storage()
        moveAppOnlyShelf(to: storage)
        let store = ShelfStore(storage: storage) { Date() } didSave: {
            widgets.reloadAllTimelines()
        }
        store.load()
        return store
    }

    /// Brings a shelf saved before the widgets existed into the shared container, once.
    private static func moveAppOnlyShelf(to storage: FileShelfStorage) {
        let old = FileShelfStorage.appOnly.fileURL
        let files = FileManager.default
        guard old != storage.fileURL,
              files.fileExists(atPath: old.path(percentEncoded: false)),
              !files.fileExists(atPath: storage.fileURL.path(percentEncoded: false)) else { return }
        try? files.moveItem(at: old, to: storage.fileURL)
    }
}
