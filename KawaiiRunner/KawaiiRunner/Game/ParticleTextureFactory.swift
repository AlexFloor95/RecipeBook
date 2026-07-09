import SpriteKit
import UIKit

/// Generates small soft-edged particle textures at runtime using Core
/// Graphics, so every particle effect in the game (sparkles, dust, confetti,
/// trails) works out of the box with zero image assets. Swap any of these
/// for hand-painted sprites later by dropping a same-named image into
/// Assets.xcassets and loading it with `SKTexture(imageNamed:)` instead.
enum ParticleTextureFactory {
    /// Cache so repeated calls with the same parameters don't re-render.
    private static var cache: [String: SKTexture] = [:]

    /// A soft radial-gradient dot, useful for sparkles, dust puffs and confetti.
    static func softDot(color: UIColor, diameter: CGFloat = 24) -> SKTexture {
        let key = "dot_\(color.particleCacheKey)_\(diameter)"
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            let colors = [color.withAlphaComponent(0.95).cgColor, color.withAlphaComponent(0.0).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: diameter / 2, y: diameter / 2), startRadius: 0,
                endCenter: CGPoint(x: diameter / 2, y: diameter / 2), endRadius: diameter / 2,
                options: []
            )
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }

    /// A tiny rounded rectangle "confetti" chip.
    static func confettiChip(color: UIColor, size: CGSize = CGSize(width: 10, height: 14)) -> SKTexture {
        let key = "confetti_\(color.particleCacheKey)_\(size.width)x\(size.height)"
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 3)
            color.setFill()
            path.fill()
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }

    /// A tiny star shape, used for the Combo Move burst and star pickups.
    static func star(color: UIColor, diameter: CGFloat = 20) -> SKTexture {
        let key = "star_\(color.particleCacheKey)_\(diameter)"
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            let center = CGPoint(x: diameter / 2, y: diameter / 2)
            let path = UIBezierPath()
            let points = 5
            let outerRadius = diameter / 2
            let innerRadius = outerRadius * 0.45
            for i in 0..<(points * 2) {
                let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
                let angle = (CGFloat(i) * .pi / CGFloat(points)) - .pi / 2
                let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            path.close()
            color.setFill()
            path.fill()
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }
}

private extension UIColor {
    /// `UIColor.hashValue` isn't guaranteed collision-free across visually
    /// distinct colors, so cache keys are built from the actual RGBA
    /// components instead — the same approach `GradientTextureFactory` uses.
    var particleCacheKey: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%.3f-%.3f-%.3f-%.3f", r, g, b, a)
    }
}
