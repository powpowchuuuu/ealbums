import SwiftUI
import WidgetKit

/// Nothing on the shelf yet: a white note on black.
struct EmptyShelfWidget: View {
    var body: some View {
        Image(systemName: "music.note")
            .font(.largeTitle.bold())
            .foregroundStyle(.white)
            .accessibilityLabel("No albums yet")
            .containerBackground(for: .widget) {
                LinearGradient.monochrome
            }
    }
}
