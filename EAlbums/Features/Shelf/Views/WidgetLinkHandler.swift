import SwiftUI

/// Passes the album of a tapped widget cover on to the music app. Widgets can only open their own app, so the music link
/// arrives inside an `ealbums://` link; it is opened once the app is active, or iOS may ignore the hand-off.
struct WidgetLinkHandler: ViewModifier {
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var pendingMusic: URL?

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                pendingMusic = MusicLink.musicURL(from: url)
                openPendingMusic()
            }
            .onChange(of: scenePhase) { openPendingMusic() }
    }

    private func openPendingMusic() {
        guard scenePhase == .active, let music = pendingMusic else { return }
        pendingMusic = nil
        openURL(music)
    }
}

extension View {
    /// Opens in the music app the album a tapped widget asks for.
    func opensWidgetLinks() -> some View {
        modifier(WidgetLinkHandler())
    }
}
