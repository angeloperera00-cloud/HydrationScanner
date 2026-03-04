import SwiftUI

@main
struct HydrationScannerNewApp: App {
    var body: some Scene {
        WindowGroup {
            // Dark-mode only UI
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
