import SpriteKit
import UIKit

/// A single hazard scrolling toward the player. Visuals are a soft gradient
/// "sticker" card with a warm cautionary border, a grounded drop shadow, a
/// gentle idle wobble, plus an emoji placeholder label
/// (see `ObstacleType.placeholderEmoji`) — swap `buildPlaceholderVisual` for
/// real sprite art later.
final class ObstacleNode: SKNode {
    let obstacleType: ObstacleType

    init(type: ObstacleType, groundY: CGFloat) {
        self.obstacleType = type
        super.init()
        name = "obstacle"
        buildPlaceholderVisual()
        configurePhysics()
        positionRelativeToGround(groundY: groundY, type: type)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildPlaceholderVisual() {
        let cardSize = CGSize(width: obstacleType.width, height: obstacleType.height)

        let shadow = SKSpriteNode(texture: GradientTextureFactory.softShadow(size: CGSize(width: cardSize.width * 0.9, height: cardSize.height * 0.35)))
        shadow.size = CGSize(width: cardSize.width * 0.9, height: cardSize.height * 0.35)
        shadow.position = CGPoint(x: 0, y: -cardSize.height / 2 + 4)
        shadow.zPosition = -1
        addChild(shadow)

        let card = SKSpriteNode(texture: GradientTextureFactory.roundedGradientCard(
            topColor: UIColor(hex: "#FFF6E9"),
            bottomColor: UIColor(hex: "#FFDCC2"),
            size: cardSize,
            cornerRadius: 16,
            borderColor: UIColor(hex: "#FF8A65"),
            borderWidth: 3
        ))
        card.size = cardSize
        addChild(card)

        let label = SKLabelNode(text: obstacleType.placeholderEmoji)
        label.fontSize = min(obstacleType.width, obstacleType.height) * 0.85
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: -2)
        addChild(label)

        // A gentle, slightly-worried idle wobble so obstacles never look
        // inert — skipped when the player has turned on Reduce Motion in
        // Settings, since this is purely decorative ambient motion.
        guard !SaveManager.shared.profile.settings.reduceMotion else { return }
        let wobble = SKAction.sequence([
            .rotate(byAngle: 0.06, duration: 0.5),
            .rotate(byAngle: -0.12, duration: 1.0),
            .rotate(byAngle: 0.06, duration: 0.5),
        ])
        wobble.timingMode = .easeInEaseOut
        run(.repeatForever(wobble))
    }

    private func configurePhysics() {
        let body = SKPhysicsBody(rectangleOf: CGSize(width: obstacleType.width * 0.8, height: obstacleType.height * 0.8))
        body.isDynamic = false
        body.categoryBitMask = PhysicsCategory.obstacle
        body.collisionBitMask = PhysicsCategory.none
        body.contactTestBitMask = PhysicsCategory.player
        physicsBody = body
    }

    /// Ground-based obstacles sit on the ground; the flying crow hovers at
    /// head height so it must be slid under rather than jumped over.
    private func positionRelativeToGround(groundY: CGFloat, type: ObstacleType) {
        switch type.avoidance {
        case .slideUnder:
            position.y = groundY + 70
        default:
            position.y = groundY + obstacleType.height / 2
        }
    }
}
