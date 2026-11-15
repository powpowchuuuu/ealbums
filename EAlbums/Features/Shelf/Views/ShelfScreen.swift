import SwiftUI

/// "Albums": what the user keeps, in two columns, with "+" to add from Apple Music and the sort and filter menu.
struct ShelfScreen: View {
    @Environment(ShelfStore.self) private var shelf
    @State private var adding = false

    var body: some View {
        @Bindable var shelf = shelf
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Albums")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                    if shelf.entries.isEmpty {
                        EmptyShelfView()
                    } else {
                        ShelfList()
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .toolbar { ShelfToolbar(adding: $adding) }
            .sheet(isPresented: $adding) {
                AddReleaseSheet()
            }
            .alert("Couldn't save your albums", isPresented: $shelf.saveFailed) {
                Button("OK") {}
            }
        }
    }
}

/// "+" and the sort and filter menu, each in its own glass circle.
private struct ShelfToolbar: ToolbarContent {
    @Binding var adding: Bool

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Add", systemImage: "plus") { adding = true }
        }
        ToolbarSpacer(.fixed, placement: .topBarTrailing)
        ToolbarItem(placement: .topBarTrailing) {
            ShelfFilterMenu()
        }
    }
}

/// The search bar, then the kept releases; each opens in Apple Music.
private struct ShelfList: View {
    @Environment(ShelfStore.self) private var shelf
    @Environment(\.openURL) private var openURL
    @FocusState private var typing: Bool

    var body: some View {
        @Bindable var shelf = shelf
        SearchField(prompt: "Search", text: $shelf.query.text, focus: $typing)
            .padding(.horizontal, 16)
        if shelf.visible.isEmpty {
            ContentUnavailableView.search(text: shelf.query.text)
                .padding(.top, 80)
        } else {
            ReleaseGrid(releases: shelf.visible.map(\.release)) { release in
                Button {
                    if let url = release.url { openURL(url) }
                } label: {
                    ReleaseTile(release: release)
                }
                .buttonStyle(.plain)
                .contextMenu { menu(for: release) }
            }
            .padding(.top, 10)
        }
    }

    @ViewBuilder private func menu(for release: Release) -> some View {
        if let url = release.url {
            Button("Open in Apple Music", systemImage: "music.note") { openURL(url) }
        }
        Button("Remove", systemImage: "trash", role: .destructive) {
            withAnimation { shelf.remove(release.id) }
        }
    }
}

/// A big grey note and "Add an album to begin".
private struct EmptyShelfView: View {
    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "music.note")
                .font(.system(size: 120))
                .foregroundStyle(Color(.systemGray5))
                .accessibilityHidden(true)
            Text("Add an album to begin")
                .font(.headline)
                .foregroundStyle(Color(.systemGray3))
        }
        .frame(maxWidth: .infinity)
        .containerRelativeFrame(.vertical) { height, _ in height * 0.75 }
    }
}

#if DEBUG
#Preview {
    ShelfScreen()
        .environment(ShelfStore(storage: FileShelfStorage(fileURL: URL.temporaryDirectory.appending(path: "p.json"))))
        .environment(CatalogSearchStore(catalog: PreviewMusicCatalog()))
}
#endif
