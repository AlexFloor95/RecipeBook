import SwiftUI
import UIKit

/// Shared hex-color parsing so SwiftUI (`Color`), UIKit/SpriteKit (`UIColor`)
/// and the world/character/theme models (which store plain hex strings) all
/// agree on one palette without duplicating literals.
extension UIColor {
    convenience init(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        sanitized.removeAll { $0 == "#" }

        var rgbValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgbValue)

        let r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgbValue & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}

extension Color {
    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex))
    }

    /// A lighter variant of this color, used to build the subtle top-to-
    /// bottom gradients that give buttons/cards a glossy "candy" look
    /// instead of a flat fill.
    func kawaiiLightened(by fraction: CGFloat = 0.14) -> Color {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: max(0, s - fraction * 0.5), brightness: min(1, b + fraction), opacity: a)
    }

    /// A darker variant of this color, used for the base of glossy gradients
    /// and for subtle pressed/shaded states.
    func kawaiiDarkened(by fraction: CGFloat = 0.14) -> Color {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(self).getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return Color(hue: h, saturation: min(1, s + fraction * 0.3), brightness: max(0, b * (1 - fraction)), opacity: a)
    }

    /// A soft top-to-bottom gradient from a lightened to a base/darkened
    /// tone of this color — the one gradient recipe reused by every glossy
    /// button/card/badge in the app.
    var kawaiiGlossyGradient: LinearGradient {
        LinearGradient(colors: [kawaiiLightened(), self], startPoint: .top, endPoint: .bottom)
    }
}

/// Semantic app-wide kawaii palette, layered on top of the raw per-world hex
/// values so UI code reads as `KawaiiPalette.mochiPink` rather than magic hex.
enum KawaiiPalette {
    static let mochiPink = Color(hex: "#FF8FB1")
    static let skyBlue = Color(hex: "#8FD3FF")
    static let matchaGreen = Color(hex: "#9FE0AE")
    static let creamWhite = Color(hex: "#FFF8F0")
    static let lavender = Color(hex: "#C6A8FF")
    static let honeyYellow = Color(hex: "#FFD97A")
    static let cocoaBrown = Color(hex: "#8B6A5A")
    static let textDark = Color(hex: "#4A3B36")
}
