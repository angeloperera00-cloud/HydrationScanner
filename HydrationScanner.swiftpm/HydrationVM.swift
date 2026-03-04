import SwiftUI
import UIKit

final class HydrationVM: ObservableObject {
    @Published var lastImage: UIImage? = nil
    @Published var analyzedColor: UIColor? = nil
    @Published var matchedShade: HydrationShade? = nil
    @Published var deltaE: Double? = nil
    @Published var entries: [HydrationEntry] = HydrationEntry.load()

    func select(shade: HydrationShade) {
        matchedShade = shade; analyzedColor = shade.uiColor; deltaE = 0
    }

    func analyze(image: UIImage) {
        lastImage = image
        guard let avg = ImageAnalyzer.averageColor(from: image) else { return }
        let lab = LAB(from: avg)
        var best: (HydrationShade, Double)?
        for s in HydrationShade.palette {
            let d = LAB.deltaE(lab, s.lab)
            if best == nil || d < best!.1 { best = (s, d) }
        }
        analyzedColor = avg; matchedShade = best?.0; deltaE = best?.1
    }

    func saveResult() {
        guard let s = matchedShade else { return }
        let e = HydrationEntry(date: .now, shadeId: s.id)
        entries.insert(e, at: 0); HydrationEntry.save(entries)
    }
}
