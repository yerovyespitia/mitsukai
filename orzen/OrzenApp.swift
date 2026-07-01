import SwiftUI

@main
struct OrzenApp: App {
    var body: some Scene {
        #if os(macOS)
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
        #else
        WindowGroup {
            ContentView()
                .task {
                    await LaunchCatalogPrefetcher.prefetchInitialCatalogs()
                }
        }
        #endif
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
