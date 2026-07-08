import SpriteKit
import UIKit

/// A procedurally-drawn placeholder body for Debbie or Alex: a rounded blob
/// body, two round ears, big dot eyes, blush circles and a tiny curved
/// mouth — the "kleine gezichtjes op voorwerpen" cuteness from the brief,
/// achieved with `SKShapeNode`s so the game runs with zero sprite assets.
///
/// Replace this entirely with a real `SKSpriteNode` + texture atlas once art
/// is ready; nothing else in `PlayerNode` depends on how the figure is drawn
/// internally, only on its node hierarchy for adding effects as children.
final class CharacterFigureNode: SKNode {
    let character: CharacterType
    let isLead: Bool
    private var glowNode: SKShapeNode?

    init(character: CharacterType, isLead: Bool) {
        self.character = character
        self.isLead = isLead
        super.init()
        buildFigure()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildFigure() {
        let bodyColor = UIColor(hex: character.themeColorHex)
        let bodyRadius: CGFloat = isLead ? 26 : 22

        // Body (rounded blob)
        let body = SKShapeNode(circleOfRadius: bodyRadius)
        body.fillColor = bodyColor
        body.strokeColor = bodyColor.withAlphaComponent(0.4)
        body.lineWidth = 2
        body.position = CGPoint(x: 0, y: bodyRadius + 6)
        addChild(body)

        // Ears
        for xOffset in [-bodyRadius * 0.7, bodyRadius * 0.7] {
            let ear = SKShapeNode(circleOfRadius: bodyRadius * 0.32)
            ear.fillColor = bodyColor
            ear.strokeColor = .clear
            ear.position = CGPoint(x: xOffset, y: body.position.y + bodyRadius * 0.85)
            addChild(ear)
        }

        // Eyes
        for xOffset in [-bodyRadius * 0.35, bodyRadius * 0.35] {
            let eye = SKShapeNode(circleOfRadius: bodyRadius * 0.11)
            eye.fillColor = .black
            eye.strokeColor = .clear
            eye.position = CGPoint(x: xOffset, y: body.position.y + bodyRadius * 0.1)
            addChild(eye)
        }

        // Blush
        for xOffset in [-bodyRadius * 0.55, bodyRadius * 0.55] {
            let blush = SKShapeNode(circleOfRadius: bodyRadius * 0.14)
            blush.fillColor = UIColor(hex: "#FF6F91").withAlphaComponent(0.5)
            blush.strokeColor = .clear
            blush.position = CGPoint(x: xOffset, y: body.position.y - bodyRadius * 0.05)
            addChild(blush)
        }

        // Mouth
        let mouthPath = CGMutablePath()
        mouthPath.addArc(center: .zero, radius: bodyRadius * 0.18, startAngle: .pi * 1.15, endAngle: .pi * 1.85, clockwise: false)
        let mouth = SKShapeNode(path: mouthPath)
        mouth.strokeColor = .black
        mouth.lineWidth = 1.5
        mouth.position = CGPoint(x: 0, y: body.position.y - bodyRadius * 0.2)
        addChild(mouth)

        // Feet (two small ellipses that "run" via animation in PlayerNode)
        for xOffset: CGFloat in [-bodyRadius * 0.4, bodyRadius * 0.4] {
            let foot = SKShapeNode(ellipseOf: CGSize(width: bodyRadius * 0.5, height: bodyRadius * 0.28))
            foot.fillColor = bodyColor.withAlphaComponent(0.85)
            foot.strokeColor = .clear
            foot.position = CGPoint(x: xOffset, y: 4)
            addChild(foot)
        }
    }

    /// Toggles a soft pulsing outline glow, used to show Combo Move invincibility.
    func setGlowing(_ active: Bool) {
        if active {
            guard glowNode == nil else { return }
            let glow = SKShapeNode(circleOfRadius: 34)
            glow.strokeColor = UIColor(hex: "#FFD166")
            glow.lineWidth = 4
            glow.fillColor = .clear
            glow.position = CGPoint(x: 0, y: 32)
            glow.glowWidth = 8
            glow.alpha = 0.85
            glow.run(.repeatForever(.sequence([.scale(to: 1.15, duration: 0.35), .scale(to: 1.0, duration: 0.35)])))
            insertChild(glow, at: 0)
            glowNode = glow
        } else {
            glowNode?.removeFromParent()
            glowNode = nil
        }
    }
}
