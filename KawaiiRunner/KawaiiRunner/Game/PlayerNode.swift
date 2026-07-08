import SpriteKit
import UIKit

/// Every state the running duo can be in. Drives both physics-body shape
/// (sliding uses a short, wide body; everything else a taller capsule) and
/// which procedural animation is currently playing.
enum PlayerState: Equatable {
    case running
    case jumping
    case doubleJumping
    case sliding
    case dashing
    case dead
}

/// The player-controlled node: a duo of two simple, round, kawaii character
/// figures (drawn procedurally from shapes since no sprite art ships with
/// this scaffold — see `CharacterFigureNode`) that share one physics body.
///
/// `PlayerNode` owns real SpriteKit physics (an `SKPhysicsBody` affected by
/// the scene's gravity) for jumping/falling, while `GameScene` is
/// responsible for translating touch gestures into calls like `jump()`.
final class PlayerNode: SKNode {
    private(set) var state: PlayerState = .running
    private(set) var isShielded = false
    private(set) var isComboInvincible = false
    private(set) var isMagnetActive = false

    private let leadFigure: CharacterFigureNode
    private let buddyFigure: CharacterFigureNode
    private var shieldAuraNode: SKEmitterNode?
    private var dashTrailNode: SKEmitterNode?

    private var jumpsUsedThisAirtime = 0
    private let runningBodySize = CGSize(width: 46, height: 84)
    private let slidingBodySize = CGSize(width: 60, height: 44)

    /// Ground-level Y in scene coordinates; set by `GameScene` on layout.
    var groundY: CGFloat = 0

    init(lead: CharacterType) {
        leadFigure = CharacterFigureNode(character: lead, isLead: true)
        buddyFigure = CharacterFigureNode(character: lead.partner, isLead: false)
        super.init()

        buddyFigure.position = CGPoint(x: -30, y: 18)
        buddyFigure.setScale(0.78)
        buddyFigure.alpha = 0.92
        addChild(buddyFigure)
        addChild(leadFigure)

        let body = SKPhysicsBody(rectangleOf: runningBodySize, center: CGPoint(x: 0, y: runningBodySize.height / 2))
        body.affectedByGravity = true
        body.allowsRotation = false
        body.categoryBitMask = PhysicsCategory.player
        body.collisionBitMask = PhysicsCategory.ground
        body.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.collectible | PhysicsCategory.ground
        physicsBody = body

        playRunAnimation()
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Movement actions

    /// Ground jump. Ignored if airborne already (double jump handles that case).
    func jump() {
        guard state == .running || state == .sliding else { return }
        endSlideBodyIfNeeded()
        state = .jumping
        jumpsUsedThisAirtime = 1
        physicsBody?.velocity.dy = 0
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 620))
        HapticsManager.shared.impact(.light)
        AudioManager.shared.playSFX(.jump)
        playJumpAnimation()
    }

    /// Second mid-air jump. Only valid once per airtime.
    func doubleJump() {
        guard state == .jumping, jumpsUsedThisAirtime == 1 else { return }
        state = .doubleJumping
        jumpsUsedThisAirtime = 2
        physicsBody?.velocity.dy = 0
        physicsBody?.applyImpulse(CGVector(dx: 0, dy: 560))
        HapticsManager.shared.impact(.medium)
        AudioManager.shared.playSFX(.doubleJump)
        playDoubleJumpAnimation()
    }

    /// Begins a slide: shrinks the physics body and crouches the figures so
    /// head-height obstacles (crows) can be passed underneath.
    func startSlide() {
        guard state == .running else { return }
        state = .sliding
        physicsBody = SKPhysicsBody(rectangleOf: slidingBodySize, center: CGPoint(x: 0, y: slidingBodySize.height / 2))
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.ground
        physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.collectible | PhysicsCategory.ground
        AudioManager.shared.playSFX(.slide)
        playSlideAnimation()
    }

    func endSlide() {
        guard state == .sliding else { return }
        endSlideBodyIfNeeded()
        state = .running
        playRunAnimation()
    }

    private func endSlideBodyIfNeeded() {
        guard state == .sliding else { return }
        physicsBody = SKPhysicsBody(rectangleOf: runningBodySize, center: CGPoint(x: 0, y: runningBodySize.height / 2))
        physicsBody?.affectedByGravity = true
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.player
        physicsBody?.collisionBitMask = PhysicsCategory.ground
        physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.collectible | PhysicsCategory.ground
    }

    /// Dash: brief burst of invincibility that also lets the duo punch
    /// straight through a `.dashOrShield` obstacle.
    func startDash() {
        state = .dashing
        let trail = ParticleFactory.dashTrail(color: UIColor(hex: leadFigure.character.themeColorHex))
        trail.position = CGPoint(x: -20, y: 40)
        addChild(trail)
        dashTrailNode = trail
        AudioManager.shared.playSFX(.dash)
        HapticsManager.shared.impact(.heavy)
        run(.sequence([
            .scaleX(to: 1.15, y: 0.9, duration: 0.1),
            .scaleX(to: 1.0, y: 1.0, duration: 0.1),
        ]))
    }

    func endDash() {
        guard state == .dashing else { return }
        state = .running
        dashTrailNode?.particleBirthRate = 0
        dashTrailNode?.run(.sequence([.wait(forDuration: 0.4), .removeFromParent()]))
        dashTrailNode = nil
        playRunAnimation()
    }

    // MARK: - Power-ups & assists

    func setMagnetActive(_ active: Bool) {
        isMagnetActive = active
    }

    func setShielded(_ active: Bool) {
        isShielded = active
        if active {
            let aura = ParticleFactory.shieldAura(color: KawaiiPalette.uiColorSkyBlue)
            aura.position = CGPoint(x: -14, y: 40)
            addChild(aura)
            shieldAuraNode = aura
        } else {
            shieldAuraNode?.particleBirthRate = 0
            shieldAuraNode?.run(.sequence([.wait(forDuration: 0.6), .removeFromParent()]))
            shieldAuraNode = nil
        }
    }

    func setComboInvincible(_ active: Bool) {
        isComboInvincible = active
        leadFigure.setGlowing(active)
        buddyFigure.setGlowing(active)
    }

    /// Called by `GameScene` when the player touches an obstacle. Returns
    /// `true` if this contact should end the run, `false` if a shield/combo
    /// absorbed it (and the shield is consumed if applicable).
    func handleObstacleContact() -> Bool {
        if isComboInvincible || state == .dashing { return false }
        if isShielded {
            setShielded(false)
            AudioManager.shared.playSFX(.shieldBreak)
            HapticsManager.shared.warning()
            return false
        }
        state = .dead
        return true
    }

    func landed() {
        guard state == .jumping || state == .doubleJumping else { return }
        jumpsUsedThisAirtime = 0
        state = .running
        ParticleFactory.fireAndForget(ParticleFactory.dustPuff(), at: CGPoint(x: 0, y: 4), in: self)
        playRunAnimation()
    }

    // MARK: - Procedural animations (no sprite atlas required)

    private func playRunAnimation() {
        removeAction(forKey: "pose")
        let bob = SKAction.sequence([
            .moveBy(x: 0, y: 4, duration: 0.15),
            .moveBy(x: 0, y: -4, duration: 0.15),
        ])
        leadFigure.run(.repeatForever(bob), withKey: "pose")
        buddyFigure.run(.repeatForever(bob.reversed()), withKey: "pose")
    }

    private func playJumpAnimation() {
        leadFigure.removeAction(forKey: "pose")
        leadFigure.run(.sequence([.scaleX(to: 0.9, y: 1.15, duration: 0.1), .scaleX(to: 1, y: 1, duration: 0.15)]))
    }

    private func playDoubleJumpAnimation() {
        leadFigure.run(.rotate(byAngle: .pi * 2, duration: 0.35))
        ParticleFactory.fireAndForget(ParticleFactory.collectSparkle(color: .white), at: .zero, in: self)
    }

    private func playSlideAnimation() {
        leadFigure.removeAction(forKey: "pose")
        buddyFigure.removeAction(forKey: "pose")
        leadFigure.run(.scaleX(to: 1.2, y: 0.6, duration: 0.12))
        buddyFigure.run(.scaleX(to: 1.2, y: 0.6, duration: 0.12))
    }

}

private extension KawaiiPalette {
    static var uiColorSkyBlue: UIColor { UIColor(hex: "#8FD3FF") }
}
