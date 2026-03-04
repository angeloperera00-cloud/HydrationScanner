import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - LAB Color Space

struct LAB {
    let L: Double
    let a: Double
    let b: Double
}

extension LAB {
    init(from color: UIColor) {
        // ✅ FIX: rename tuple component 'b' to avoid clashing with LAB.b
        let (r, g, bl) = color.rgb

        func invGamma(_ u: Double) -> Double {
            u <= 0.04045 ? u / 12.92 : pow((u + 0.055) / 1.055, 2.4)
        }

        let R = invGamma(r)
        let G = invGamma(g)
        let B = invGamma(bl)

        // sRGB D65
        let X = (0.4124564 * R + 0.3575761 * G + 0.1804375 * B) / 0.95047
        let Y = (0.2126729 * R + 0.7151522 * G + 0.0721750 * B)
        let Z = (0.0193339 * R + 0.1191920 * G + 0.9503041 * B) / 1.08883

        func f(_ t: Double) -> Double {
            t > pow(6.0 / 29.0, 3)
            ? pow(t, 1.0 / 3.0)
            : (1.0 / 3.0) * pow(29.0 / 6.0, 2) * t + 4.0 / 29.0
        }

        let fx = f(X), fy = f(Y), fz = f(Z)

        self.L = 116 * fy - 16
        self.a = 500 * (fx - fy)
        self.b = 200 * (fy - fz)
    }

    static func deltaE(_ p1: LAB, _ p2: LAB) -> Double {
        sqrt(pow(p1.L - p2.L, 2) + pow(p1.a - p2.a, 2) + pow(p1.b - p2.b, 2))
    }
}

// MARK: - Image Analysis

enum ImageAnalyzer {
    static func averageColor(from image: UIImage) -> UIColor? {
        guard let input = CIImage(image: image) else { return nil }

        // ✅ FIX: requires CoreImage.CIFilterBuiltins
        let filter = CIFilter.areaAverage()
        filter.inputImage = input
        filter.extent = input.extent

        let context = CIContext(options: [.workingColorSpace: NSNull()])
        guard let outImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: 1
        )
    }
}

// MARK: - UIColor Helpers

extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var v: UInt64 = 0
        Scanner(string: h).scanHexInt64(&v)

        let r = CGFloat((v >> 16) & 0xFF) / 255.0
        let g = CGFloat((v >> 8) & 0xFF) / 255.0
        let b = CGFloat(v & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1)
    }

    var rgb: (Double, Double, Double) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b))
    }
}
