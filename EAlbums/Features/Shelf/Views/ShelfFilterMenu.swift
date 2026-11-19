import SwiftUI

/// The sliders button: the order of the shelf, which kind it shows, and where "+" searches.
struct ShelfFilterMenu: View {
    @Environment(ShelfStore.self) private var shelf
    @Environment(ServiceStore.self) private var services

    var body: some View {
        @Bindable var shelf = shelf
        @Bindable var services = services
        Menu("Options", systemImage: "slider.horizontal.3") {
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
            Picker("Add From", selection: $services.service) {
                ForEach(MusicService.allCases, id: \.self) { service in
                    Text(service.name).tag(service)
                }
            }
        }
    }
}
