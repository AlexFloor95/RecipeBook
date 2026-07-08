import SpriteKit
import UIKit

/// Generates soft, glossy gradient textures at runtime using Core Graphics —
/// the same "no art assets needed" trick as `ParticleTextureFactory`, applied
/// to the bigger shapes (character bodies, obstacle/collectible cards, sky)
/// so the whole game reads as painted rather than flat-filled vector shapes.
///
/// SpriteKit shape gradients normally require a custom `SKShader` (GLSL);
/// baking a gradient into a `UIImage` once and wrapping it in `SKTexture` is
/// simpler, has zero runtime shader-compile risk, and is fast because every
/// texture is cached and reused across every node that needs the same look.
enum GradientTextureFactory {
    private static var cache: [String: SKTexture] = [:]

    /// A glossy, sphere-shaded circle: a warm highlight offset toward the
    /// upper-left fading through the base color into a darker rim shadow.
    /// This single trick is what makes flat character blobs read as soft,
    /// squishy 3D mochi rather than paper cutouts.
    static func shadedSphere(baseColor: UIColor, diameter: CGFloat) -> SKTexture {
        let key = "sphere_\(baseColor.kawaiiCacheKey)_\(diameter)"
        if let cached = cache[key] { return cached }

        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0
        baseColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        let highlight = UIColor(hue: hue, saturation: max(0, sat - 0.28), brightness: min(1, bri + 0.30), alpha: alpha)
        let rimShadow = UIColor(hue: hue, saturation: min(1, sat + 0.08), brightness: max(0, bri - 0.20), alpha: alpha)

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
        let image = renderer.image { context in
            let cg = context.cgContext
            cg.addEllipse(in: CGRect(x: 0, y: 0, width: diameter, height: diameter))
            cg.clip()
            let colors = [highlight.cgColor, baseColor.cgColor, rimShadow.cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.55, 1.0])!
            cg.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: diameter * 0.36, y: diameter * 0.68), startRadius: 0,
                endCenter: CGPoint(x: diameter * 0.5, y: diameter * 0.5), endRadius: diameter * 0.72,
                options: [.drawsAfterEndLocation]
            )
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }

    /// A soft rounded card with a top-to-bottom gradient and optional
    /// colored border — used for obstacle/collectible/power-up backdrops so
    /// they feel like little cut-paper stickers instead of plain rectangles.
    static func roundedGradientCard(
        topColor: UIColor, bottomColor: UIColor, size: CGSize,
        cornerRadius: CGFloat, borderColor: UIColor? = nil, borderWidth: CGFloat = 3
    ) -> SKTexture {
        let key = "card_\(topColor.kawaiiCacheKey)_\(bottomColor.kawaiiCacheKey)_\(size.width)x\(size.height)_\(cornerRadius)_\(borderColor?.kawaiiCacheKey ?? "none")"
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cg = context.cgContext
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            cg.saveGState()
            path.addClip()
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            cg.drawLinearGradient(gradient, start: CGPoint(x: rect.midX, y: rect.minY), end: CGPoint(x: rect.midX, y: rect.maxY), options: [])
            cg.restoreGState()
            if let borderColor {
                borderColor.setStroke()
                path.lineWidth = borderWidth
                path.stroke()
            }
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }

    /// A soft, blurred elliptical drop shadow — anchors floating nodes
    /// (characters, obstacles, collectibles) visually to the ground instead
    /// of looking like they're pasted on top of the scene.
    static func softShadow(size: CGSize, opacity: CGFloat = 0.28) -> SKTexture {
        let key = "shadow_\(size.width)x\(size.height)_\(opacity)"
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cg = context.cgContext
            cg.saveGState()
            cg.translateBy(x: size.width / 2, y: size.height / 2)
            cg.scaleBy(x: 1, y: size.height / size.width)
            let colors = [UIColor.black.withAlphaComponent(opacity).cgColor, UIColor.black.withAlphaComponent(0).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            cg.drawRadialGradient(gradient, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: size.width / 2, options: [])
            cg.restoreGState()
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }

    /// A full-bleed vertical gradient, used for the sky backdrop per world.
    static func verticalGradient(topColor: UIColor, bottomColor: UIColor, size: CGSize) -> SKTexture {
        let key = "vgrad_\(topColor.kawaiiCacheKey)_\(bottomColor.kawaiiCacheKey)_\(size.width)x\(size.height)"
        if let cached = cache[key] { return cached }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1])!
            context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: size.width / 2, y: 0), end: CGPoint(x: size.width / 2, y: size.height), options: [])
        }
        let texture = SKTexture(image: image)
        cache[key] = texture
        return texture
    }
}

private extension UIColor {
    /// `UIColor.hashValue` isn't stable across colors created via different
    /// initializers with the same visual value, so cache keys are built from
    /// the actual RGBA components instead.
    var kawaiiCacheKey: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%.3f-%.3f-%.3f-%.3f", r, g, b, a)
    }
}
