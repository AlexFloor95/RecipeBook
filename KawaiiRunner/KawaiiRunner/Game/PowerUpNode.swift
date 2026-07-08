import SpriteKit
import UIKit

/// A rare pickup granting the Magnet or Shield power-up. Shares the
/// `collectible` physics category with `CollectibleNode` (both are things
/// the player "collects" on contact) but is modeled separately since
/// activating a power-up has gameplay side effects rather than just scoring.
final class PowerUpNode: SKNode {
    let powerUpType: PowerUpType
    private static let radius: CGFloat = 24

    init(type: PowerUpType, groundY: CGFloat, laneHeight: CGFloat) {
        self.powerUpType = type
        super.init()
        name = "powerUp"
        buildPlaceholderVisual()
        configurePhysics()
        position.y = groundY + laneHeight

        run(.repeatForever(.sequence([
            .scale(to: 1.15, duration: 0.4),
            .scale(to: 1.0, duration: 0.4),
        ])))
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildPlaceholderVisual() {
        let ring = SKShapeNode(circleOfRadius: Self.radius)
        ring.fillColor = UIColor(hex: "#FFD166").withAlphaComponent(0.85)
        ring.strokeColor = .white
        ring.lineWidth = 2
        addChild(ring)

        let label = SKLabelNode(text: powerUpType.placeholderEmoji)
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
}
