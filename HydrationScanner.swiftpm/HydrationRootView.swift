import SwiftUI

struct HydrationRootView: View {
    @StateObject private var vm = HydrationVM()

    var body: some View {
        TabView {
            NavigationStack {
                HydrationCheckScreen(vm: vm)
            }
            .tabItem { Label("Check", systemImage: "drop.fill") }

            NavigationStack {
                HydrationHistoryScreen(vm: vm)
            }
            .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
        }
        // Dark-mode only UI
        .preferredColorScheme(.dark)
    }
}
