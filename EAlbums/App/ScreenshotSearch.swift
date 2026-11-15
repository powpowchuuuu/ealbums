import SwiftUI

#if DEBUG
/// `-screenshotSearch <words>` on launch (Debug only): opens the add sheet already searching, for README screenshots.
private struct ScreenshotSearch: ViewModifier {
    @Environment(CatalogSearchStore.self) private var search
    @Binding var adding: Bool

    func body(content: Content) -> some View {
        content.task {
            guard let words = UserDefaults.standard.string(forKey: "screenshotSearch") else { return }
            search.term = words
            adding = true
        }
    }
}
#endif

extension View {
    /// Opens the add sheet on a search given at launch, in Debug builds; does nothing in Release.
    @ViewBuilder
    func screenshotSearch(adding: Binding<Bool>) -> some View {
        #if DEBUG
        modifier(ScreenshotSearch(adding: adding))
        #else
        self
        #endif
    }
}
