import SwiftUI

@main
struct MitsukaiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1280, minHeight: 980)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
} 