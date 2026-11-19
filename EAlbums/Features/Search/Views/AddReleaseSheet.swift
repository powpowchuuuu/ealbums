import SwiftUI

/// Searching Apple Music or YouTube Music, as picked in the options: a glass search bar and a close button on one line, then the results.
/// Tap a release to keep it (dimmed once kept), tap again to take it off.
struct AddReleaseSheet: View {
    @Environment(ShelfStore.self) private var shelf
    @Environment(CatalogSearchStore.self) private var search
    @Environment(\.dismiss) private var dismiss
    @FocusState private var typing: Bool

    var body: some View {
        results
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .scrollEdgeEffectStyle(.soft, for: .top)
            .safeAreaBar(edge: .top) {
                searchRow
            }
            .task(id: search.term) {
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
                await search.search()
            }
            .onAppear { typing = true }
            .onDisappear { search.reset() }
    }

    /// The glass search bar and the close button, floating over the results as they scroll under.
    private var searchRow: some View {
        @Bindable var search = search
        return GlassEffectContainer(spacing: 12) {
            HStack(spacing: 12) {
                SearchField(text: $search.term, focus: $typing)
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3.weight(.medium))
                        .frame(width: SearchField.height, height: SearchField.height)
                        .contentShape(.circle)
                }
                .accessibilityLabel("Close")
                .buttonStyle(.plain)
                .glassEffect(.regular.interactive(), in: .circle)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
    }

    @ViewBuilder private var results: some View {
        switch search.phase {
        case .idle:
            Color.clear

        case .searching:
            ProgressView()

        case .results(let releases):
            ScrollView {
                ReleaseGrid(releases: releases) { release in
                    Button {
                        withAnimation(.snappy) { shelf.toggle(release) }
                    } label: {
                        ReleaseTile(release: release, dimmed: shelf.contains(release.id))
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.selection, trigger: shelf.contains(release.id))
                }
            }
            .scrollDismissesKeyboard(.immediately)

        case .noResults:
            ContentUnavailableView.search(text: search.term)

        case .notAuthorized:
            ContentUnavailableView(
                "Apple Music Access Needed",
                systemImage: "music.note",
                description: Text(
                    "Allow EAlbums to use Apple Music in Settings, or pick YouTube Music in the Albums options."
                )
            )

        case .failed(let reason):
            ContentUnavailableView("Search Failed", systemImage: "wifi.exclamationmark", description: Text(reason))
        }
    }
}
