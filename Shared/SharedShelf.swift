import Foundation

/// Where the app and its widgets find the shelf: a file in their shared App Group container.
nonisolated enum SharedShelf {
    /// The App Group both targets belong to: "group." and the app's bundle id, whichever of them asks.
    static func groupIdentifier(bundleID: String) -> String {
        let appID = bundleID.hasSuffix(".Widgets") ? String(bundleID.dropLast(".Widgets".count)) : bundleID
        return "group.\(appID)"
    }

    /// The shelf file in the group container; Application Support when the group is not available.
    static func storage(bundle: Bundle = .main) -> FileShelfStorage {
        FileShelfStorage(fileURL: folder(bundle: bundle).appending(path: "shelf.json"))
    }

    private static func folder(bundle: Bundle) -> URL {
        let bundleID = bundle.bundleIdentifier ?? ""
        let group = groupIdentifier(bundleID: bundleID)
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group)
        return container ?? .applicationSupportDirectory
    }
}
