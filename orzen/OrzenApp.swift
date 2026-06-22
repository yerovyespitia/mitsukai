import SwiftUI

@main
struct OrzenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1280, minHeight: 780)
                .task {
                    await LaunchCatalogPrefetcher.prefetchInitialCatalogs()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}

private enum LaunchCatalogPrefetcher {
    @MainActor
    static func prefetchInitialCatalogs() async {
        async let home: Void = HomeCatalogStore.shared.prefetchIfNeeded()
        async let moviesAndSeries: Void = CinemetaCatalogPresets.prefetchInitialCatalogs()

        _ = await (home, moviesAndSeries)
    }
}
