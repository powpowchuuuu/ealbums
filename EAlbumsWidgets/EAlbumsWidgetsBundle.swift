import SwiftUI
import WidgetKit

@main
struct EAlbumsWidgetsBundle: WidgetBundle {
    var body: some Widget {
        CoverWidget()
        ShelfWidget()
    }
}
