import SwiftUI

struct HeroCard: View {
    @ObservedObject var vm: HydrationVM
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle().fill(Color(uiColor: vm.analyzedColor ?? .systemGray5)).frame(width: 54, height: 54)
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.matchedShade?.level.rawValue ?? "No reading yet").font(.title3.weight(.semibold))
                    if let d = vm.deltaE {
                        Text("Match confidence: ΔE \(d, specifier: "%.1f")").font(.subheadline).foregroundStyle(.secondary)
                    } else {
                        Text("Scan or choose a shade to get a recommendation.").font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            if let s = vm.matchedShade {
                Text(s.recommendation).font(.callout).foregroundStyle(.secondary)
            } else {
                Text("Tip: Use natural light and avoid colored bathroom lighting for best results.").font(.callout).foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
    }
}

struct ResultSection: View {
    @ObservedObject var vm: HydrationVM
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack { Text("Result").font(.headline); Spacer() }
            if let shade = vm.matchedShade {
                ResultCard(shade: shade, exampleColor: Color(uiColor: vm.analyzedColor ?? shade.uiColor), deltaE: vm.deltaE)
            } else {
                PlaceholderCard()
            }
        }
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
    }
}

struct SaveRow: View {
    @ObservedObject var vm: HydrationVM
    var body: some View {
        Button { vm.saveResult() } label: {
            HStack { Image(systemName: "square.and.arrow.down"); Text("Save to History").fontWeight(.semibold) }
                .frame(maxWidth: .infinity)
        }.buttonStyle(.borderedProminent).disabled(vm.matchedShade == nil)
    }
}

struct PrivacyNote: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Private & offline").font(.subheadline.weight(.semibold))
            Text("Your data stays on your device. Images are never uploaded.")
            Text("Guidance is informational and not medical advice.")
        }.font(.callout).foregroundStyle(.secondary).multilineTextAlignment(.center)
    }
}

struct ActionTile: View {
    let title: String; let subtitle: String; let systemImage: String; let isProminent: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill(isProminent ? Color.accentColor : Color.primary.opacity(0.08)).frame(width: 44, height: 44)
                    Image(systemName: systemImage).font(.system(size: 18, weight: .semibold)).foregroundStyle(isProminent ? .white : .primary)
                }
                VStack(alignment: .leading, spacing: 2) { Text(title).font(.headline); Text(subtitle).font(.subheadline).foregroundStyle(.secondary) }
                Spacer()
            }.padding(14).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 22))
        }.buttonStyle(.plain)
    }
}

struct ResultCard: View {
    let shade: HydrationShade; let exampleColor: Color; let deltaE: Double?
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "drop.fill").font(.system(size: 48)).foregroundStyle(exampleColor)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hydration Level: \(shade.level.rawValue)").font(.title3).bold()
                    if let d = deltaE { Text(String(format: "Match confidence ΔE: %.1f (lower is better)", d)).font(.footnote).foregroundStyle(.secondary) }
                }
                Spacer()
            }
            Text("💧 \(shade.recommendation)").font(.callout)
        }.padding().background(shade.color.opacity(0.12)).clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct PlaceholderCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "drop.fill").font(.system(size: 48)).foregroundStyle(Color.yellow.opacity(0.5))
                VStack(alignment: .leading) {
                    Text("No scan yet").font(.title3).bold()
                    Text("Scan or select a color to see your hydration level.").font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
            }
        }.padding().background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct HistoryRow: View {
    let entry: HydrationEntry; let shade: HydrationShade
    var body: some View {
        HStack(spacing: 12) {
            Circle().fill(shade.color).frame(width: 16, height: 16)
            VStack(alignment: .leading, spacing: 2) {
                Text(shade.level.rawValue).font(.headline)
                Text(entry.date.formatted(date: .abbreviated, time: .shortened)).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
        }.padding(12).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
