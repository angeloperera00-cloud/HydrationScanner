import SwiftUI

struct HydrationHistoryScreen: View {
    @ObservedObject var vm: HydrationVM

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if vm.entries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text("No saved results")
                        .font(.title3.weight(.semibold))

                    Text("Save a hydration result to see it here.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
            } else {
                List {
                    ForEach(vm.entries) { e in
                        if let shade = HydrationShade.palette.first(where: { $0.id == e.shadeId }) {
                            HistoryRow(entry: e, shade: shade)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("History")
    }
}
