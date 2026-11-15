import SwiftUI
import WidgetKit

/// The latest albums as floating covers over a blur of the newest one, nothing else: three in a row, or nine.
struct ShelfWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Shelf", provider: ShelfProvider()) { moment in
            ShelfWidgetView(moment: moment)
        }
        .configurationDisplayName("Albums")
        .description("Your latest albums, a tap away.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

private struct ShelfWidgetView: View {
    let moment: ShelfMoment
    @Environment(\.widgetFamily) private var family

    private let columns = 3
    private var slots: Int { family == .systemLarge ? 9 : 3 }

    var body: some View {
        if moment.releases.isEmpty {
            EmptyShelfWidget()
        } else {
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                ForEach(rows, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { index in
                            slot(at: index)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(for: .widget) {
                BlurredBackdrop(image: moment.releases.first.flatMap { moment.artwork[$0.id] })
            }
        }
    }

    private var rows: [[Int]] {
        stride(from: 0, to: slots, by: columns).map { Array($0..<min($0 + columns, slots)) }
    }

    @ViewBuilder private func slot(at index: Int) -> some View {
        if index < moment.releases.count {
            let release = moment.releases[index]
            if let link = MusicLink.widgetURL(for: release.url) {
                Link(destination: link) { CoverTile(image: moment.artwork[release.id]) }
            } else {
                CoverTile(image: moment.artwork[release.id])
            }
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.12))
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

/// A floating square cover with soft corners and a shadow.
private struct CoverTile: View {
    let image: UIImage?

    var body: some View {
        ArtworkFill(image: image)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(.rect(cornerRadius: 10))
            .shadow(color: .black.opacity(0.35), radius: 6, y: 3)
    }
}

/// The newest cover, blurred and dimmed, as the widget's background.
private struct BlurredBackdrop: View {
    let image: UIImage?

    var body: some View {
        ArtworkFill(image: image)
            .blur(radius: 28)
            .overlay(Color.black.opacity(0.35))
    }
}
