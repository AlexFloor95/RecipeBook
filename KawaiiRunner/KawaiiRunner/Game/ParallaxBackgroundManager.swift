import SpriteKit
import UIKit

/// Draws and scrolls the four-layer parallax backdrop (gradient sky with a
/// sun/moon, drifting clouds, mid-ground props, ground strip) for the
/// currently active `WorldTheme`, and cross-fades to a new palette when the
/// world changes. Each layer scrolls at a different fraction of the world's
/// speed — the classic parallax trick that sells depth cheaply — and props
/// are simple rounded rectangles, enough to convey theme without art.
final class ParallaxBackgroundManager {
    private weak var scene: SKScene?
    private var skySprite: SKSpriteNode!
    private var celestialBody: SKShapeNode!
    private var cloudLayer: SKNode!
    private var midgroundLayer: SKNode!
    private var groundNode: SKSpriteNode!
    private var groundDecor: SKNode!
    private var midgroundProps: [SKShapeNode] = []
    private var clouds: [SKNode] = []

    private(set) var currentTheme: WorldTheme = .mochiCafe
    let groundHeight: CGFloat = 140

    /// Layers scroll slower the further back they sit, creating depth.
    private let cloudParallaxFactor: CGFloat = 0.18
    private let midgroundParallaxFactor: CGFloat = 0.5
    private static let groundDecorDotCount = 40
    private static let groundDecorSpacing: CGFloat = 40
    private static let groundDecorPatternWidth: CGFloat = CGFloat(groundDecorDotCount) * groundDecorSpacing

    init(scene: SKScene) {
        self.scene = scene
        buildLayers()
        applyTheme(.mochiCafe, animated: false)
    }

    private func buildLayers() {
        guard let scene else { return }

        // Sky: full-bleed gradient texture, replaced (not re-drawn) on theme change.
        skySprite = SKSpriteNode(texture: GradientTextureFactory.verticalGradient(
            topColor: UIColor(hex: WorldTheme.mochiCafe.skyTopHex),
            bottomColor: UIColor(hex: WorldTheme.mochiCafe.skyHex),
            size: scene.size
        ))
        skySprite.size = scene.size
        skySprite.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        skySprite.zPosition = -40
        scene.addChild(skySprite)

        // Sun / moon, parked in the upper sky.
        celestialBody = SKShapeNode(circleOfRadius: 34)
        celestialBody.position = CGPoint(x: scene.size.width * 0.76, y: scene.size.height * 0.8)
        celestialBody.zPosition = -35
        celestialBody.strokeColor = .clear
        celestialBody.glowWidth = 10
        scene.addChild(celestialBody)

        // Clouds: soft rounded-rect clusters drifting slowly in the far distance.
        cloudLayer = SKNode()
        cloudLayer.zPosition = -30
        scene.addChild(cloudLayer)
        for i in 0..<4 {
            let cloud = makeCloud()
            cloud.position = CGPoint(
                x: CGFloat(i) * (scene.size.width / 2.2),
                y: scene.size.height * CGFloat.random(in: 0.62...0.85)
            )
            cloudLayer.addChild(cloud)
            clouds.append(cloud)
        }

        // Mid-ground props (buildings/bushes/lanterns depending on world).
        midgroundLayer = SKNode()
        midgroundLayer.zPosition = -20
        scene.addChild(midgroundLayer)
        for i in 0..<6 {
            let prop = SKShapeNode()
            prop.path = Self.randomPropPath()
            prop.strokeColor = .clear
            prop.alpha = 0.9
            prop.position = CGPoint(x: CGFloat(i) * (scene.size.width / 3), y: groundHeight + 40)
            midgroundLayer.addChild(prop)
            midgroundProps.append(prop)
        }

        // Ground: gradient strip with a soft top highlight edge + simple dot texture for grass/cobble feel.
        groundNode = SKSpriteNode(texture: GradientTextureFactory.verticalGradient(
            topColor: UIColor(hex: WorldTheme.mochiCafe.groundHex),
            bottomColor: UIColor(hex: WorldTheme.mochiCafe.groundHex).kawaiiDarkened(by: 0.18),
            size: CGSize(width: scene.size.width * 4, height: groundHeight)
        ))
        groundNode.size = CGSize(width: scene.size.width * 4, height: groundHeight)
        groundNode.position = CGPoint(x: scene.size.width / 2, y: groundHeight / 2)
        groundNode.zPosition = -10
        scene.addChild(groundNode)

        groundDecor = SKNode()
        groundDecor.zPosition = -9
        scene.addChild(groundDecor)
        for i in 0..<Self.groundDecorDotCount {
            let dot = SKShapeNode(circleOfRadius: 3)
            dot.strokeColor = .clear
            dot.fillColor = UIColor.white.withAlphaComponent(0.18)
            dot.position = CGPoint(x: CGFloat(i) * Self.groundDecorSpacing - scene.size.width, y: groundHeight - CGFloat.random(in: 10...30))
            groundDecor.addChild(dot)
        }

        let groundBody = SKPhysicsBody(rectangleOf: CGSize(width: scene.size.width * 4, height: groundHeight), center: .zero)
        groundBody.isDynamic = false
        groundBody.categoryBitMask = PhysicsCategory.ground
        groundBody.collisionBitMask = PhysicsCategory.player
        groundBody.contactTestBitMask = PhysicsCategory.player
        groundNode.physicsBody = groundBody
    }

    private func makeCloud() -> SKNode {
        let cloud = SKNode()
        let puffCount = Int.random(in: 3...4)
        for i in 0..<puffCount {
            let puff = SKSpriteNode(texture: ParticleTextureFactory.softDot(color: .white, diameter: 60))
            puff.size = CGSize(width: CGFloat.random(in: 46...70), height: CGFloat.random(in: 36...54))
            puff.position = CGPoint(x: CGFloat(i) * 24, y: CGFloat.random(in: -6...6))
            puff.alpha = 0.8
            cloud.addChild(puff)
        }
        return cloud
    }

    /// The Y coordinate the player's feet should rest on.
    var groundSurfaceY: CGFloat { groundHeight }

    func applyTheme(_ theme: WorldTheme, animated: Bool) {
        currentTheme = theme
        let skyTop = UIColor(hex: theme.skyTopHex)
        let skyBottom = UIColor(hex: theme.skyHex)
        let mid = UIColor(hex: theme.midgroundHex)
        let ground = UIColor(hex: theme.groundHex)
        let celestial = UIColor(hex: theme.celestialHex)

        let newSkyTexture = GradientTextureFactory.verticalGradient(topColor: skyTop, bottomColor: skyBottom, size: skySprite.size)
        let newGroundTexture = GradientTextureFactory.verticalGradient(topColor: ground, bottomColor: ground.kawaiiDarkened(by: 0.18), size: groundNode.size)

        if animated, let scene {
            // Crossfade via a temporary overlay, since a sprite's texture
            // can't be interpolated directly between two bitmaps.
            let overlay = SKSpriteNode(texture: newSkyTexture)
            overlay.size = skySprite.size
            overlay.position = skySprite.position
            overlay.zPosition = skySprite.zPosition + 1
            overlay.alpha = 0
            scene.addChild(overlay)
            overlay.run(.fadeAlpha(to: 1, duration: 1.2)) { [weak self] in
                self?.skySprite.texture = newSkyTexture
                overlay.removeFromParent()
            }
            celestialBody.run(.sequence([.fadeOut(withDuration: 0.5), .run { [weak self] in self?.celestialBody.fillColor = celestial }, .fadeIn(withDuration: 0.5)]))
            groundNode.run(.sequence([.fadeAlpha(to: 0.4, duration: 0.4), .run { [weak self] in self?.groundNode.texture = newGroundTexture }, .fadeAlpha(to: 1, duration: 0.4)]))
        } else {
            skySprite.texture = newSkyTexture
            celestialBody.fillColor = celestial
            groundNode.texture = newGroundTexture
        }

        celestialBody.glowWidth = theme.isNight ? 6 : 14
        midgroundProps.forEach { $0.fillColor = mid }
    }

    /// Scrolls the background layers leftward with the world, each at its
    /// own parallax fraction, and recycles props/clouds once they exit the
    /// left edge to create an endless strip.
    func scroll(by dx: CGFloat) {
        guard let scene else { return }

        for cloud in clouds {
            cloud.position.x -= dx * cloudParallaxFactor
            if cloud.position.x < -140 {
                cloud.position.x += scene.size.width + 140
                cloud.position.y = scene.size.height * CGFloat.random(in: 0.62...0.85)
            }
        }

        for prop in midgroundProps {
            prop.position.x -= dx * midgroundParallaxFactor
            if prop.position.x < -80 {
                prop.position.x += scene.size.width + 80 * CGFloat(midgroundProps.count)
                prop.path = Self.randomPropPath()
            }
        }

        // The dot pattern repeats every `groundDecorPatternWidth` points, so
        // wrapping by exactly that distance keeps the tiling seamless
        // regardless of the device's actual screen width.
        groundDecor.position.x -= dx
        if groundDecor.position.x < -Self.groundDecorPatternWidth {
            groundDecor.position.x += Self.groundDecorPatternWidth
        }
    }

    /// A random mid-ground silhouette: mostly plain rounded buildings/bushes,
    /// but every so often a slender gate tower with a peaked roof — a quiet
    /// nod to the Drogenapstoren back home in Zutphen, tucked into the
    /// skyline where only the person who put it there will ever notice.
    private static func randomPropPath() -> CGPath {
        if Double.random(in: 0...1) < 0.18 {
            return towerPath()
        }
        let height = CGFloat.random(in: 60...140)
        return CGPath(
            roundedRect: CGRect(x: -30, y: -height / 2, width: 60, height: height),
            cornerWidth: 16, cornerHeight: 16, transform: nil
        )
    }

    private static func towerPath() -> CGPath {
        let width: CGFloat = 34
        let bodyHeight: CGFloat = 150
        let roofHeight: CGFloat = 46
        let path = CGMutablePath()
        let base = CGRect(x: -width / 2, y: -bodyHeight / 2, width: width, height: bodyHeight)
        path.addRoundedRect(in: base, cornerWidth: 6, cornerHeight: 6)
        path.move(to: CGPoint(x: -width / 2 - 4, y: base.maxY))
        path.addLine(to: CGPoint(x: 0, y: base.maxY + roofHeight))
        path.addLine(to: CGPoint(x: width / 2 + 4, y: base.maxY))
        path.closeSubpath()
        return path
    }
}

private extension UIColor {
    /// Returns a darker variant of this color, used to give the ground strip
    /// a subtle vertical shade instead of a completely flat fill.
    func kawaiiDarkened(by fraction: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: min(1, s + fraction * 0.2), brightness: max(0, b * (1 - fraction)), alpha: a)
    }
}
