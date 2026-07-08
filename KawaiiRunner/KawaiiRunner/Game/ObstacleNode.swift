import SpriteKit
import UIKit

/// A single hazard scrolling toward the player. Visuals are a rounded shape
/// plus an emoji placeholder label (see `ObstacleType.placeholderEmoji`) —
/// swap `buildPlaceholderVisual` for real sprite art later.
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
        let shape = SKShapeNode(rectOf: CGSize(width: obstacleType.width, height: obstacleType.height), cornerRadius: 14)
        shape.fillColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.9)
        shape.strokeColor = UIColor(hex: "#4A3B36").withAlphaComponent(0.25)
        shape.lineWidth = 2
        addChild(shape)

        let label = SKLabelNode(text: obstacleType.placeholderEmoji)
        label.fontSize = min(obstacleType.width, obstacleType.height) * 0.9
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
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
