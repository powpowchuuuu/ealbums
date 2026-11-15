import SwiftUI
import WidgetKit

/// A cover filling its frame, or a white note on black while there is no artwork.
struct ArtworkFill: View {
    let image: UIImage?

    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .widgetAccentedRenderingMode(.accentedDesaturated)
                .scaledToFill()
                .accessibilityHidden(true)
        } else {
            LinearGradient.monochrome
                .overlay {
                    Image(systemName: "music.note")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.6))
                        .accessibilityHidden(true)
                }
        }
    }
}

extension LinearGradient {
    /// Black, a touch lighter at the top left, as the app icon.
    static let monochrome = LinearGradient(
        colors: [Color(white: 0.23), .black],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
