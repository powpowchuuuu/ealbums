import SwiftUI

/// Two columns of releases.
struct ReleaseGrid<Tile: View>: View {
    let releases: [Release]
    @ViewBuilder let tile: (Release) -> Tile

    private let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
            ForEach(releases) { release in
                tile(release)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
