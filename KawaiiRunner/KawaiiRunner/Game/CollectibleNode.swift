import SpriteKit
import UIKit

/// A single pickup scrolling toward the player. When the run's Magnet
/// power-up is active, `GameScene` steers nearby collectibles toward the
/// player each frame via `attract(towards:deltaTime:)`.
final class CollectibleNode: SKNode {
    let collectibleType: CollectibleType
    private static let radius: CGFloat = 22

    init(type: CollectibleType, groundY: CGFloat, laneHeight: CGFloat) {
        self.collectibleType = type
        super.init()
        name = "collectible"
        buildPlaceholderVisual()
        configurePhysics()
        position.y = groundY + laneHeight

        // Gentle bob + gentle scale pulse so pickups feel alive and inviting.
        run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 8, duration: 0.5),
            .moveBy(x: 0, y: -8, duration: 0.5),
        ])))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildPlaceholderVisual() {
        let accentColor = UIColor(hex: collectibleType.accentHex)
        let diameter = Self.radius * 2

        // Soft outer glow ring, gently pulsing to draw the eye without
        // being distracting during fast-paced play.
        let glow = SKSpriteNode(texture: ParticleTextureFactory.softDot(color: accentColor, diameter: diameter * 1.9))
        glow.size = CGSize(width: diameter * 1.9, height: diameter * 1.9)
        glow.alpha = 0.55
        glow.zPosition = -1
        addChild(glow)
        glow.run(.repeatForever(.sequence([
            .scale(to: 1.15, duration: 0.6),
            .scale(to: 0.95, duration: 0.6),
        ])))

        // Glossy backing sphere instead of a flat white disc.
        let backing = SKSpriteNode(texture: GradientTextureFactory.shadedSphere(baseColor: accentColor, diameter: diameter))
        backing.size = CGSize(width: diameter, height: diameter)
        addChild(backing)

        let ring = SKShapeNode(circleOfRadius: Self.radius)
        ring.strokeColor = .white
        ring.lineWidth = 2
        ring.fillColor = .clear
        ring.alpha = 0.8
        addChild(ring)

        let label = SKLabelNode(text: collectibleType.placeholderEmoji)
        label.fontSize = Self.radius * 1.5
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

    /// Pulls this collectible toward `target` at a fixed speed. Used only
    /// while the run's Magnet power-up is active.
    func attract(towards target: CGPoint, deltaTime: TimeInterval) {
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = max(1, (dx * dx + dy * dy).squareRoot())
        let speed: CGFloat = 900
        let step = min(distance, speed * CGFloat(deltaTime))
        position.x += dx / distance * step
        position.y += dy / distance * step
    }

    func playCollectedEffect(in scene: SKNode) {
        let tint = UIColor(hex: collectibleType.accentHex)
        ParticleFactory.fireAndForget(ParticleFactory.collectSparkle(color: tint), at: position, in: scene)
        removeFromParent()
    }
}
