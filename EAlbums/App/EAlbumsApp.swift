import SwiftUI

@main
struct EAlbumsApp: App {
    @State private var shelf = AppConfiguration.shelf()
    @State private var services = AppConfiguration.services()
    @State private var search = CatalogSearchStore(catalog: AppConfiguration.catalog())

    var body: some Scene {
        WindowGroup {
            ShelfScreen()
                .environment(shelf)
                .environment(services)
                .environment(search)
                .fontDesign(.rounded)
        }
    }
}
