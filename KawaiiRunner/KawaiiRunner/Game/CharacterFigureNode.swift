import SpriteKit
import UIKit

/// A procedurally-drawn placeholder body for Debbie or Alex: a glossy,
/// sphere-shaded blob body (see `GradientTextureFactory.shadedSphere`), a
/// soft ground shadow, round ears, big sparkly eyes with a blink loop,
/// blush circles, a tiny curved mouth, and a small character-specific
/// accessory (Debbie's bow / Alex's leaf) — the "kleine gezichtjes op
/// voorwerpen" cuteness from the brief, achieved entirely with runtime-baked
/// textures and `SKShapeNode`s so the game runs with zero sprite assets.
///
/// Replace this entirely with a real `SKSpriteNode` + texture atlas once art
/// is ready; nothing else in `PlayerNode` depends on how the figure is drawn
/// internally, only on its node hierarchy for adding effects as children.
final class CharacterFigureNode: SKNode {
    let character: CharacterType
    let isLead: Bool
    private var glowNode: SKShapeNode?
    private var eyes: [SKShapeNode] = []

    init(character: CharacterType, isLead: Bool) {
        self.character = character
        self.isLead = isLead
        super.init()
        buildFigure()
        startBlinking()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func buildFigure() {
        let bodyColor = UIColor(hex: character.themeColorHex)
        let bodyRadius: CGFloat = isLead ? 26 : 22
        let bodyCenter = CGPoint(x: 0, y: bodyRadius + 6)

        // Soft ground shadow, anchored under the feet regardless of body shading.
        let shadow = SKSpriteNode(texture: GradientTextureFactory.softShadow(size: CGSize(width: bodyRadius * 1.7, height: bodyRadius * 0.7)))
        shadow.size = CGSize(width: bodyRadius * 1.7, height: bodyRadius * 0.7)
        shadow.position = CGPoint(x: 0, y: -2)
        shadow.zPosition = -1
        addChild(shadow)

        // Body: glossy sphere-shaded blob instead of a flat fill.
        let bodyDiameter = bodyRadius * 2
        let body = SKSpriteNode(texture: GradientTextureFactory.shadedSphere(baseColor: bodyColor, diameter: bodyDiameter))
        body.size = CGSize(width: bodyDiameter, height: bodyDiameter)
        body.position = bodyCenter
        addChild(body)

        // Ears — small shaded spheres to match the body's glossy look.
        let earDiameter = bodyRadius * 0.64
        for xOffset in [-bodyRadius * 0.7, bodyRadius * 0.7] {
            let ear = SKSpriteNode(texture: GradientTextureFactory.shadedSphere(baseColor: bodyColor, diameter: earDiameter))
            ear.size = CGSize(width: earDiameter, height: earDiameter)
            ear.position = CGPoint(x: xOffset, y: bodyCenter.y + bodyRadius * 0.85)
            ear.zPosition = -0.5
            addChild(ear)
        }

        // Eyes — bigger, glossy dot with a small white highlight for sparkle.
        for xOffset in [-bodyRadius * 0.36, bodyRadius * 0.36] {
            let eye = SKShapeNode(circleOfRadius: bodyRadius * 0.13)
            eye.fillColor = UIColor(hex: "#2E2340")
            eye.strokeColor = .clear
            eye.position = CGPoint(x: xOffset, y: bodyCenter.y + bodyRadius * 0.1)
            addChild(eye)
            eyes.append(eye)

            let sparkle = SKShapeNode(circleOfRadius: bodyRadius * 0.045)
            sparkle.fillColor = .white
            sparkle.strokeColor = .clear
            sparkle.position = CGPoint(x: eye.position.x - bodyRadius * 0.045, y: eye.position.y + bodyRadius * 0.05)
            addChild(sparkle)
        }

        // Blush — soft radial glow rather than a flat circle.
        for xOffset in [-bodyRadius * 0.58, bodyRadius * 0.58] {
            let blushDiameter = bodyRadius * 0.5
            let blush = SKSpriteNode(texture: ParticleTextureFactory.softDot(color: UIColor(hex: "#FF6F91"), diameter: blushDiameter))
            blush.size = CGSize(width: blushDiameter, height: blushDiameter)
            blush.alpha = 0.75
            blush.position = CGPoint(x: xOffset, y: bodyCenter.y - bodyRadius * 0.05)
            addChild(blush)
        }

        // Mouth
        let mouthPath = CGMutablePath()
        mouthPath.addArc(center: .zero, radius: bodyRadius * 0.18, startAngle: .pi * 1.15, endAngle: .pi * 1.85, clockwise: false)
        let mouth = SKShapeNode(path: mouthPath)
        mouth.strokeColor = UIColor(hex: "#2E2340")
        mouth.lineWidth = 1.5
        mouth.lineCap = .round
        mouth.position = CGPoint(x: 0, y: bodyCenter.y - bodyRadius * 0.2)
        addChild(mouth)

        // Character-specific accessory for silhouette variety at a glance.
        addAccessory(bodyRadius: bodyRadius, bodyCenter: bodyCenter)

        // Feet (two small glossy ellipses that "run" via animation in PlayerNode)
        for xOffset: CGFloat in [-bodyRadius * 0.4, bodyRadius * 0.4] {
            let foot = SKShapeNode(ellipseOf: CGSize(width: bodyRadius * 0.5, height: bodyRadius * 0.28))
            foot.fillColor = bodyColor.withAlphaComponent(0.85)
            foot.strokeColor = .clear
            foot.position = CGPoint(x: xOffset, y: 4)
            addChild(foot)
        }
    }

    /// Debbie gets a little bow, Alex gets a little leaf sprig — a cheap way
    /// to make the duo instantly distinguishable beyond just body tint.
    private func addAccessory(bodyRadius: CGFloat, bodyCenter: CGPoint) {
        let topOfHead = CGPoint(x: bodyRadius * 0.15, y: bodyCenter.y + bodyRadius * 0.92)
        switch character {
        case .debbie:
            let bowColor = UIColor(hex: "#FF4F81")
            let leftWing = SKShapeNode(ellipseOf: CGSize(width: bodyRadius * 0.34, height: bodyRadius * 0.22))
            leftWing.fillColor = bowColor
            leftWing.strokeColor = .clear
            leftWing.zRotation = .pi / 6
            leftWing.position = CGPoint(x: topOfHead.x - bodyRadius * 0.16, y: topOfHead.y)
            addChild(leftWing)

            let rightWing = SKShapeNode(ellipseOf: CGSize(width: bodyRadius * 0.34, height: bodyRadius * 0.22))
            rightWing.fillColor = bowColor
            rightWing.strokeColor = .clear
            rightWing.zRotation = -.pi / 6
            rightWing.position = CGPoint(x: topOfHead.x + bodyRadius * 0.16, y: topOfHead.y)
            addChild(rightWing)

            let knot = SKShapeNode(circleOfRadius: bodyRadius * 0.1)
            knot.fillColor = UIColor(hex: "#D6316A")
            knot.strokeColor = .clear
            knot.position = topOfHead
            addChild(knot)
        case .alex:
            let leafColor = UIColor(hex: "#4CAF6D")
            let leaf = SKShapeNode(ellipseOf: CGSize(width: bodyRadius * 0.26, height: bodyRadius * 0.46))
            leaf.fillColor = leafColor
            leaf.strokeColor = .clear
            leaf.zRotation = .pi / 5
            leaf.position = topOfHead
            addChild(leaf)
        }
    }

    /// Slow, occasional double-blink loop so the duo never looks like a
    /// static cutout, even standing at the Character Select screen.
    private func startBlinking() {
        let blink = SKAction.sequence([
            .scaleY(to: 0.15, duration: 0.06),
            .scaleY(to: 1.0, duration: 0.08),
        ])
        let wait = SKAction.wait(forDuration: 2.4, withRange: 2.0)
        let loop = SKAction.repeatForever(.sequence([wait, blink]))
        eyes.forEach { $0.run(loop) }
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
