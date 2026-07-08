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
