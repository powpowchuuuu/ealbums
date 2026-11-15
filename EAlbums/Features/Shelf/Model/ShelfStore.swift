import Foundation
import Observation

/// The releases the user keeps, saved on every change.
@Observable
final class ShelfStore {
    private(set) var entries: [ShelfEntry] = []
    var query = ShelfQuery()
    /// Set when the last save failed, so the view can say so; the view clears it once said.
    var saveFailed = false

    private let storage: any ShelfStorage
    private let now: () -> Date

    init(storage: any ShelfStorage, now: @escaping () -> Date = Date.init) {
        self.storage = storage
        self.now = now
    }

    /// The entries the query keeps, in its order.
    var visible: [ShelfEntry] { query.apply(to: entries) }

    func load() {
        entries = (try? storage.load()) ?? []
    }

    func contains(_ id: Release.ID) -> Bool {
        entries.contains { $0.id == id }
    }

    /// Adds the release, or takes it off when it is already there.
    func toggle(_ release: Release) {
        if contains(release.id) {
            remove(release.id)
        } else {
            entries.append(ShelfEntry(release: release, addedAt: now()))
            save()
        }
    }

    func remove(_ id: Release.ID) {
        entries.removeAll { $0.id == id }
        save()
    }

    private func save() {
        do {
            try storage.save(entries)
            saveFailed = false
        } catch {
            saveFailed = true
        }
    }
}
