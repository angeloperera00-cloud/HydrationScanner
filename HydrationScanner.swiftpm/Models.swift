import SwiftUI
import UIKit

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    var colorScheme: ColorScheme? { self == .system ? nil : (self == .light ? .light : .dark) }
}

struct HydrationShade: Identifiable, Hashable {
    enum Level: String { case excellent="Very Well Hydrated", good="Well Hydrated", slightlyLow="Slightly Low", mild="Mildly Dehydrated", moderate="Dehydrated", high="Very Dehydrated", severe="Severely Dehydrated", medical="Possible Health Issue" }
    let id: Int; let hex: String; let uiColor: UIColor; let level: Level; let recommendation: String
    var color: Color { Color(uiColor) }
    var lab: LAB { LAB(from: uiColor) }
    static let palette: [HydrationShade] = [
        .init(id: 1, hex: "#FFFBEA", uiColor: .init(hex: "#FFFBEA"), level: .excellent, recommendation: "Overhydrated: Pause drinking for 1–2 hours."),
        .init(id: 2, hex: "#FFF3B0", uiColor: .init(hex: "#FFF3B0"), level: .good, recommendation: "Perfect hydration!"),
        .init(id: 3, hex: "#FFE66D", uiColor: .init(hex: "#FFE66D"), level: .slightlyLow, recommendation: "Drink 1–2 glasses soon."),
        .init(id: 4, hex: "#FFD23F", uiColor: .init(hex: "#FFD23F"), level: .mild, recommendation: "Drink 0.5–0.75 L within the next hour."),
        .init(id: 5, hex: "#E0A106", uiColor: .init(hex: "#E0A106"), level: .moderate, recommendation: "Drink 1–1.5 L over 2–3 hours."),
        .init(id: 6, hex: "#B57F00", uiColor: .init(hex: "#B57F00"), level: .high, recommendation: "Drink 1.5 L now and sip."),
        .init(id: 7, hex: "#8B5E00", uiColor: .init(hex: "#8B5E00"), level: .severe, recommendation: "Drink 1.5–2.0 L immediately."),
        .init(id: 8, hex: "#5C3D00", uiColor: .init(hex: "#5C3D00"), level: .medical, recommendation: "Consult a doctor if persistent.")
    ]
}

struct HydrationEntry: Codable, Identifiable {
    var id: UUID = .init(); var date: Date; var shadeId: Int
    static let key = "hydration_entries_v1"
    static func load() -> [HydrationEntry] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([HydrationEntry].self, from: data)) ?? []
    }
    static func save(_ entries: [HydrationEntry]) {
        if let data = try? JSONEncoder().encode(entries) { UserDefaults.standard.set(data, forKey: key) }
    }
}
