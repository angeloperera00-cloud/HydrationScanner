import SwiftUI

struct HydrationCheckScreen: View {
    @ObservedObject var vm: HydrationVM
    @State private var showCamera = false
    @State private var showManual = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    HeroCard(vm: vm)

                    HStack(spacing: 12) {
                        ActionTile(
                            title: "Scan",
                            subtitle: "Camera",
                            systemImage: "camera.viewfinder",
                            isProminent: true
                        ) { showCamera = true }

                        ActionTile(
                            title: "Pick",
                            subtitle: "Manual",
                            systemImage: "paintpalette",
                            isProminent: false
                        ) { showManual = true }
                    }

                    ResultSection(vm: vm)
                    SaveRow(vm: vm)
                    PrivacyNote()
                }
                .padding()
            }
        }
        .navigationTitle("Hydration")
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { img in
                if let img { vm.analyze(image: img) }
                showCamera = false
            }
        }
        .sheet(isPresented: $showManual) {
            ManualShadePicker(selected: vm.matchedShade) { s in
                vm.select(shade: s)
                showManual = false
            }
        }
    }
}
