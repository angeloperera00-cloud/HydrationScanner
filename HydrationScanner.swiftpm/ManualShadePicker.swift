import SwiftUI

struct ManualShadePicker: View {
    let selected: HydrationShade?
    let onPick: (HydrationShade) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                    ForEach(HydrationShade.palette) { shade in
                        Button {
                            onPick(shade); dismiss()
                        } label: {
                            VStack {
                                Image(systemName: "drop.fill").font(.system(size: 44)).foregroundStyle(shade.color)
                                Text("#\(shade.id)").font(.caption).foregroundStyle(.secondary)
                            }.padding(10).background(shade.color.opacity(selected?.id == shade.id ? 0.22 : 0.10)).clipShape(RoundedRectangle(cornerRadius: 14))
                        }.buttonStyle(.plain)
                    }
                }.padding()
            }.navigationTitle("Manual Shade")
        }
    }
}
