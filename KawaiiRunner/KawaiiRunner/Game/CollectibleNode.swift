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

        // Gentle bob so pickups feel alive even without frame animation.
        run(.repeatForever(.sequence([
            .moveBy(x: 0, y: 8, duration: 0.5),
            .moveBy(x: 0, y: -8, duration: 0.5),
        ])))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildPlaceholderVisual() {
        let glow = SKShapeNode(circleOfRadius: Self.radius)
        glow.fillColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.8)
        glow.strokeColor = .clear
        addChild(glow)

        let label = SKLabelNode(text: collectibleType.placeholderEmoji)
        label.fontSize = Self.radius * 1.6
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

    func playCollectedEffect(in scene: SKNode, accentColor: UIColor) {
        ParticleFactory.fireAndForget(ParticleFactory.collectSparkle(color: accentColor), at: position, in: scene)
        removeFromParent()
    }
}
