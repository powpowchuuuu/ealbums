import SwiftUI

/// The sliders button: the order of the shelf and which kind it shows.
struct ShelfFilterMenu: View {
    @Environment(ShelfStore.self) private var shelf

    var body: some View {
        @Bindable var shelf = shelf
        Menu("Sort and Filter", systemImage: "slider.horizontal.3") {
            Picker("Sort By", selection: $shelf.query.order) {
                ForEach(ShelfOrder.allCases, id: \.self) { order in
                    Text(order.label).tag(order)
                }
            }
            Picker("Show", selection: $shelf.query.kind) {
                Text("All").tag(ReleaseKind?.none)
                ForEach(ReleaseKind.allCases, id: \.self) { kind in
                    Text(kind.label).tag(ReleaseKind?.some(kind))
                }
            }
        }
    }
}
