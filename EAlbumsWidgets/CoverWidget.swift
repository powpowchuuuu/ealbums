import SwiftUI
import WidgetKit

/// One album cover, edge to edge, nothing else; a new one every hour.
struct CoverWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Cover", provider: CoverProvider()) { moment in
            CoverWidgetView(moment: moment)
        }
        .configurationDisplayName("Cover")
        .description("An album from your shelf, a new one every hour.")
        .supportedFamilies([.systemSmall, .systemLarge])
        .contentMarginsDisabled()
    }
}

private struct CoverWidgetView: View {
    let moment: ShelfMoment

    var body: some View {
        if let release = moment.releases.first {
            Color.clear
                .widgetURL(MusicLink.widgetURL(for: release.url))
                .containerBackground(for: .widget) {
                    ArtworkFill(image: moment.artwork[release.id])
                }
        } else {
            EmptyShelfWidget()
        }
    }
}
