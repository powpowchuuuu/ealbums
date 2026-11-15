import SwiftUI

/// A release in a grid: its square artwork, then the title and the artist on one line each.
struct ReleaseTile: View {
    let release: Release
    var dimmed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ReleaseArtwork(url: release.artworkURL)
                .padding(.bottom, 8)
            Text(release.title)
                .font(.headline)
            Text(release.artist)
                .font(.subheadline)
        }
        .lineLimit(1)
        .foregroundStyle(.primary)
        .opacity(dimmed ? 0.45 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(dimmed ? .isSelected : [])
    }
}

/// Square artwork with a hairline edge and a soft shadow; a note on grey while it loads or when there is none.
struct ReleaseArtwork: View {
    let url: URL?

    var body: some View {
        Color(.secondarySystemFill)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Image(systemName: "music.note")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
            }
            .clipShape(.rect(cornerRadius: 3))
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .strokeBorder(.primary.opacity(0.12), lineWidth: 0.5)
            }
            .shadow(color: .black.opacity(0.12), radius: 1.5, y: 1)
            .accessibilityHidden(true)
    }
}

#Preview {
    ReleaseTile(release: Release(
        id: "album:1",
        title: "Les Pêcheurs - Single",
        artist: "Lina Moreau",
        kind: .single,
        artworkURL: nil,
        url: nil
    ))
    .frame(width: 180)
}
