import SpriteKit
import UIKit

/// A rare pickup granting the Magnet or Shield power-up. Shares the
/// `collectible` physics category with `CollectibleNode` (both are things
/// the player "collects" on contact) but is modeled separately since
/// activating a power-up has gameplay side effects rather than just scoring.
/// Visually bigger, golden and rotating so it reads as a special bonus
/// rather than an ordinary pickup.
final class PowerUpNode: SKNode {
    let powerUpType: PowerUpType
    private static let radius: CGFloat = 26

    init(type: PowerUpType, groundY: CGFloat, laneHeight: CGFloat) {
        self.powerUpType = type
        super.init()
        name = "powerUp"
        buildPlaceholderVisual()
        configurePhysics()
        position.y = groundY + laneHeight

        run(.repeatForever(.sequence([
            .scale(to: 1.12, duration: 0.4),
            .scale(to: 1.0, duration: 0.4),
        ])))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildPlaceholderVisual() {
        let goldColor = UIColor(hex: "#FFD166")
        let diameter = Self.radius * 2

        // Wide, slow-pulsing glow to make the rarer power-up read as special.
        let glow = SKSpriteNode(texture: ParticleTextureFactory.softDot(color: goldColor, diameter: diameter * 2.3))
        glow.size = CGSize(width: diameter * 2.3, height: diameter * 2.3)
        glow.alpha = 0.5
        glow.zPosition = -2
        addChild(glow)
        glow.run(.repeatForever(.sequence([.scale(to: 1.2, duration: 0.7), .scale(to: 0.9, duration: 0.7)])))

        // Rotating star ring behind the badge, like a little sparkle halo.
        let starRing = SKNode()
        starRing.zPosition = -1
        for i in 0..<4 {
            let angle = CGFloat(i) * (.pi / 2)
            let star = SKSpriteNode(texture: ParticleTextureFactory.star(color: .white, diameter: 10))
            star.position = CGPoint(x: cos(angle) * Self.radius * 1.3, y: sin(angle) * Self.radius * 1.3)
            star.alpha = 0.85
            starRing.addChild(star)
        }
        starRing.run(.repeatForever(.rotate(byAngle: .pi * 2, duration: 4)))
        addChild(starRing)

        // Glossy golden badge.
        let badge = SKSpriteNode(texture: GradientTextureFactory.shadedSphere(baseColor: goldColor, diameter: diameter))
        badge.size = CGSize(width: diameter, height: diameter)
        addChild(badge)

        let ring = SKShapeNode(circleOfRadius: Self.radius)
        ring.strokeColor = .white
        ring.lineWidth = 2.5
        ring.fillColor = .clear
        addChild(ring)

        let label = SKLabelNode(text: powerUpType.placeholderEmoji)
        label.fontSize = Self.radius * 1.4
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
    }

    private func configurePhysics() {
        let body = SKPhysicsBody(circleOfRadius: Self.radius)
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.collectible
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }
}
