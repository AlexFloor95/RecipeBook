import SpriteKit
import UIKit

/// Draws and scrolls the three-layer parallax backdrop (sky, mid-ground
/// props, ground strip) for the currently active `WorldTheme`, and
/// cross-fades to a new palette when the world changes. Props (little
/// rounded "buildings"/bushes/lanterns depending on world) are simple
/// rounded rectangles — enough to sell depth and theme without needing art.
final class ParallaxBackgroundManager {
    private weak var scene: SKScene?
    private var skyNode: SKShapeNode!
    private var midgroundLayer: SKNode!
    private var groundNode: SKShapeNode!
    private var midgroundProps: [SKShapeNode] = []

    private(set) var currentTheme: WorldTheme = .mochiCafe
    let groundHeight: CGFloat = 140

    init(scene: SKScene) {
        self.scene = scene
        buildLayers()
        applyTheme(.mochiCafe, animated: false)
    }

    private func buildLayers() {
        guard let scene else { return }
        skyNode = SKShapeNode(rectOf: scene.size)
        skyNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        skyNode.zPosition = -30
        skyNode.strokeColor = .clear
        scene.addChild(skyNode)

        midgroundLayer = SKNode()
        midgroundLayer.zPosition = -20
        scene.addChild(midgroundLayer)

        for i in 0..<6 {
            let prop = SKShapeNode(rectOf: CGSize(width: 60, height: CGFloat.random(in: 60...140)), cornerRadius: 16)
            prop.strokeColor = .clear
            prop.position = CGPoint(x: CGFloat(i) * (scene.size.width / 3), y: groundHeight + 40)
            midgroundLayer.addChild(prop)
            midgroundProps.append(prop)
        }

        groundNode = SKShapeNode(rectOf: CGSize(width: scene.size.width * 4, height: groundHeight))
        groundNode.position = CGPoint(x: scene.size.width / 2, y: groundHeight / 2)
        groundNode.zPosition = -10
        groundNode.strokeColor = .clear
        scene.addChild(groundNode)

        let groundBody = SKPhysicsBody(rectangleOf: CGSize(width: scene.size.width * 4, height: groundHeight), center: .zero)
        groundBody.isDynamic = false
        groundBody.categoryBitMask = PhysicsCategory.ground
        groundBody.collisionBitMask = PhysicsCategory.player
        groundBody.contactTestBitMask = PhysicsCategory.player
        groundNode.physicsBody = groundBody
    }

    /// The Y coordinate the player's feet should rest on.
    var groundSurfaceY: CGFloat { groundHeight }

    func applyTheme(_ theme: WorldTheme, animated: Bool) {
        currentTheme = theme
        let sky = UIColor(hex: theme.skyHex)
        let mid = UIColor(hex: theme.midgroundHex)
        let ground = UIColor(hex: theme.groundHex)

        if animated, let scene {
            // Crossfade to the new sky color using a temporary overlay node,
            // since SKShapeNode's fillColor can't be animated directly.
            let overlay = SKShapeNode(rectOf: scene.size)
            overlay.position = skyNode.position
            overlay.zPosition = skyNode.zPosition + 1
            overlay.strokeColor = .clear
            overlay.fillColor = sky
            overlay.alpha = 0
            scene.addChild(overlay)
            overlay.run(.fadeAlpha(to: 1, duration: 1.2)) { [weak self] in
                self?.skyNode.fillColor = sky
                overlay.removeFromParent()
            }
        } else {
            skyNode.fillColor = sky
        }
        groundNode.fillColor = ground
        midgroundProps.forEach { $0.fillColor = mid }
    }

    /// Scrolls the mid-ground props leftward with the world; called every
    /// frame from `GameScene.update`. Recycles props once they exit the
    /// left edge to create an endless strip.
    func scroll(by dx: CGFloat) {
        guard let scene else { return }
        for prop in midgroundProps {
            prop.position.x -= dx
            if prop.position.x < -80 {
                prop.position.x += scene.size.width + 80 * CGFloat(midgroundProps.count)
                let newHeight = CGFloat.random(in: 60...140)
                prop.path = CGPath(
                    roundedRect: CGRect(x: -30, y: -newHeight / 2, width: 60, height: newHeight),
                    cornerWidth: 16, cornerHeight: 16, transform: nil
                )
            }
        }
    }
}
