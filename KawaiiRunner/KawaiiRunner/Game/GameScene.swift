import SpriteKit
import UIKit

/// The core SpriteKit scene: an endless single-lane runner where Debbie &
/// Alex auto-scroll through six kawaii worlds, dodging obstacles, gathering
/// collectibles/power-ups, and occasionally helping each other out.
///
/// Architecture note: `GameScene` is intentionally the *only* class that
/// touches SpriteKit APIs directly. Everything above it (SwiftUI views,
/// `GameViewModel`) only sees `GameHUDState` and `RunSummary` via
/// `GameSceneDelegate` — this keeps the MVVM boundary clean and the scene
/// swappable/testable independent of the UI.
final class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameDelegate: GameSceneDelegate?

    private var background: ParallaxBackgroundManager!
    private var player: PlayerNode!
    private let difficulty = DifficultyDirector()
    private let combo = ComboSystem()

    private var obstacles: [ObstacleNode] = []
    private var collectibles: [CollectibleNode] = []
    private var powerUps: [PowerUpNode] = []

    private var lastUpdateTime: TimeInterval?
    private var isRunActive = false
    private var isPaused_ = false
    private var playerAnchorX: CGFloat = 0

    private var magnetRemaining: TimeInterval = 0
    private var liftCooldownRemaining: TimeInterval = 0
    private var shieldBlockCooldownRemaining: TimeInterval = 0
    private var scoreAccumulator: Double = 0

    private var leadCharacter: CharacterType = .debbie
    private var stats = RunSummary()
    private var score = 0

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: WorldTheme.mochiCafe.skyHex)
        physicsWorld.gravity = CGVector(dx: 0, dy: -34)
        physicsWorld.contactDelegate = self
        playerAnchorX = size.width * 0.28
    }

    /// Starts (or restarts) a run with the given lead character. Safe to
    /// call repeatedly — e.g. from the "Retry" button on Game Over.
    func startNewRun(lead: CharacterType) {
        removeAllChildren()
        obstacles.removeAll()
        collectibles.removeAll()
        powerUps.removeAll()
        difficulty.reset()
        combo.reset()
        magnetRemaining = 0
        liftCooldownRemaining = 0
        shieldBlockCooldownRemaining = 0
        scoreAccumulator = 0
        score = 0
        stats = RunSummary(character: lead)
        leadCharacter = lead
        lastUpdateTime = nil
        isRunActive = true
        isPaused_ = false

        background = ParallaxBackgroundManager(scene: self)
        player = PlayerNode(lead: lead)
        player.groundY = background.groundSurfaceY
        player.position = CGPoint(x: playerAnchorX, y: background.groundSurfaceY)
        addChild(player)

        HapticsManager.shared.prepareAll()
        AudioManager.shared.playMusic(for: difficulty.currentWorld)
        reportHUD()
    }

    // MARK: - Public input API (called by GameViewModel from SwiftUI gestures)

    func handleTap() {
        guard isRunActive, !isPaused_ else { return }
        player.jump()
    }

    func handleDoubleTap() {
        guard isRunActive, !isPaused_ else { return }
        player.doubleJump()
        stats.doubleJumpUses += 1
    }

    func handleSwipeDown() {
        guard isRunActive, !isPaused_ else { return }
        player.startSlide()
        // Slides auto-release after a short window so a single swipe reads
        // as one crouch rather than requiring the player to hold anything.
        run(.sequence([.wait(forDuration: 0.55), .run { [weak self] in self?.player.endSlide() }]), withKey: "slideRelease")
    }

    func handleLongPressBegan() {
        guard isRunActive, !isPaused_ else { return }
        player.startDash()
        stats.dashUses += 1
    }

    func handleLongPressEnded() {
        guard isRunActive else { return }
        player.endDash()
    }

    /// Triggers the Team Combo Move if the shared meter is full.
    func handleComboButtonTapped() {
        guard isRunActive, !isPaused_ else { return }
        guard combo.activate(duration: BuddyAssist.comboMove.duration) else { return }
        player.setComboInvincible(true)
        stats.comboMoveActivations += 1
        AudioManager.shared.playSFX(.comboActivate)
        HapticsManager.shared.success()
        ParticleFactory.fireAndForget(ParticleFactory.comboBurst(), at: player.position, in: self)
        gameDelegate?.gameSceneDidTriggerBuddyAssist(self, assist: .comboMove)
    }

    func setPaused(_ paused: Bool) {
        isPaused_ = paused
        isPaused = paused
    }

    // MARK: - Physics contacts

    func didBegin(_ contact: SKPhysicsContact) {
        guard isRunActive else { return }
        let (playerBody, otherBody): (SKPhysicsBody, SKPhysicsBody)
        if contact.bodyA.categoryBitMask == PhysicsCategory.player {
            (playerBody, otherBody) = (contact.bodyA, contact.bodyB)
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.player {
            (playerBody, otherBody) = (contact.bodyB, contact.bodyA)
        } else {
            return
        }
        _ = playerBody

        switch otherBody.categoryBitMask {
        case PhysicsCategory.ground:
            player.landed()
        case PhysicsCategory.obstacle:
            if let obstacleNode = otherBody.node as? ObstacleNode {
                handleObstacleContact(obstacleNode)
            }
        case PhysicsCategory.collectible:
            if let collectibleNode = otherBody.node as? CollectibleNode {
                collect(collectibleNode)
            } else if let powerUpNode = otherBody.node as? PowerUpNode {
                collectPowerUp(powerUpNode)
            }
        default:
            break
        }
    }

    /// The layered "help each other" defense system described in the brief:
    /// 1) Dash/Combo invincibility always passes through for free.
    /// 2) A tall obstacle you didn't jump for may be auto-avoided by a Team
    ///    Lift, if that assist is off cooldown.
    /// 3) Otherwise an active Shield pickup absorbs the hit.
    /// 4) Otherwise, if available, Alex/Debbie steps in for a free Buddy Block.
    /// 5) Only if none of the above apply does the run actually end.
    private func handleObstacleContact(_ obstacle: ObstacleNode) {
        guard obstacles.contains(where: { $0 === obstacle }) else { return } // already resolved this frame

        if player.state == .dashing || player.isComboInvincible {
            return
        }

        if obstacle.obstacleType.avoidance == .jumpOver, player.state == .running, liftCooldownRemaining <= 0 {
            liftCooldownRemaining = BuddyAssist.lift.cooldown
            AudioManager.shared.playSFX(.buddyLift)
            HapticsManager.shared.success()
            player.run(.sequence([.moveBy(x: 0, y: 26, duration: 0.15), .moveBy(x: 0, y: -26, duration: 0.15)]))
            removeObstacle(obstacle)
            gameDelegate?.gameSceneDidTriggerBuddyAssist(self, assist: .lift)
            return
        }

        if player.isShielded {
            _ = player.handleObstacleContact() // consumes the shield, returns false
            removeObstacle(obstacle)
            return
        }

        if shieldBlockCooldownRemaining <= 0 {
            shieldBlockCooldownRemaining = BuddyAssist.shieldBlock.cooldown
            AudioManager.shared.playSFX(.shieldActivate)
            HapticsManager.shared.warning()
            removeObstacle(obstacle)
            gameDelegate?.gameSceneDidTriggerBuddyAssist(self, assist: .shieldBlock)
            return
        }

        let died = player.handleObstacleContact()
        if died {
            endRun()
        }
    }

    private func removeObstacle(_ obstacle: ObstacleNode) {
        obstacle.removeFromParent()
        obstacles.removeAll { $0 === obstacle }
    }

    private func collect(_ node: CollectibleNode) {
        let type = node.collectibleType
        stats.coinsCollected += type.coinValue
        stats.cocoTokensCollected += type.cocoTokenValue
        stats.xpEarned += type.xpValue
        switch type {
        case .mochi: stats.mochiCollected += 1
        case .bubbleTea: stats.bubbleTeaCollected += 1
        case .catPaw: stats.catPawsCollected += 1
        default: break
        }
        combo.addCharge(type.comboMeterContribution)
        score += Int(20.0 * combo.scoreMultiplier)
        AudioManager.shared.playSFX(type.collectSoundEffect)
        node.playCollectedEffect(in: self, accentColor: UIColor(hex: difficulty.currentWorld.accentHex))
        collectibles.removeAll { $0 === node }
    }

    private func collectPowerUp(_ node: PowerUpNode) {
        switch node.powerUpType {
        case .magnet:
            magnetRemaining = PowerUpType.magnet.duration
            player.setMagnetActive(true)
            stats.magnetActivations += 1
        case .shield:
            player.setShielded(true)
        }
        AudioManager.shared.playSFX(node.powerUpType.activateSoundEffect)
        HapticsManager.shared.success()
        node.removeFromParent()
        powerUps.removeAll { $0 === node }
    }

    // MARK: - Update loop

    override func update(_ currentTime: TimeInterval) {
        guard isRunActive, !isPaused_ else { lastUpdateTime = currentTime; return }
        defer { lastUpdateTime = currentTime }
        guard let last = lastUpdateTime else { return }
        let deltaTime = min(1.0 / 30.0, currentTime - last) // clamp to avoid huge jumps after backgrounding

        let world = difficulty.currentWorld
        if world != background.currentTheme {
            background.applyTheme(world, animated: true)
            AudioManager.shared.playMusic(for: world)
        }

        let scrollDelta = difficulty.advance(deltaTime: deltaTime)
        background.scroll(by: scrollDelta)
        scrollAndRecycle(scrollDelta: scrollDelta)
        spawnIfNeeded()

        liftCooldownRemaining = max(0, liftCooldownRemaining - deltaTime)
        shieldBlockCooldownRemaining = max(0, shieldBlockCooldownRemaining - deltaTime)

        if magnetRemaining > 0 {
            magnetRemaining -= deltaTime
            if magnetRemaining <= 0 {
                player.setMagnetActive(false)
            } else {
                for collectible in collectibles where distance(collectible.position, player.position) < PowerUpType.magnet.magnetRadius {
                    collectible.attract(towards: player.position, deltaTime: deltaTime)
                }
            }
        }

        if combo.tick(deltaTime: deltaTime) {
            player.setComboInvincible(false)
        }

        scoreAccumulator += Double(scrollDelta) * 0.28 * combo.scoreMultiplier
        while scoreAccumulator >= 1 {
            score += 1
            scoreAccumulator -= 1
        }

        reportHUD()
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return (dx * dx + dy * dy).squareRoot()
    }

    private func scrollAndRecycle(scrollDelta: CGFloat) {
        for node in obstacles { node.position.x -= scrollDelta }
        for node in collectibles { node.position.x -= scrollDelta }
        for node in powerUps { node.position.x -= scrollDelta }

        let cutoff: CGFloat = -160
        obstacles.filter { $0.position.x < cutoff }.forEach { $0.removeFromParent() }
        obstacles.removeAll { $0.position.x < cutoff }
        collectibles.filter { $0.position.x < cutoff }.forEach { $0.removeFromParent() }
        collectibles.removeAll { $0.position.x < cutoff }
        powerUps.filter { $0.position.x < cutoff }.forEach { $0.removeFromParent() }
        powerUps.removeAll { $0.position.x < cutoff }
    }

    private func spawnIfNeeded() {
        let spawnX = size.width + 60
        let groundY = background.groundSurfaceY

        if let obstacleType = difficulty.obstacleToSpawnIfDue() {
            let node = ObstacleNode(type: obstacleType, groundY: groundY)
            node.position.x = spawnX
            addChild(node)
            obstacles.append(node)
        }

        if let collectibleType = difficulty.collectibleToSpawnIfDue() {
            let laneHeight: CGFloat = [30, 90, 150].randomElement()!
            let node = CollectibleNode(type: collectibleType, groundY: groundY, laneHeight: laneHeight)
            node.position.x = spawnX + CGFloat.random(in: -20...20)
            addChild(node)
            collectibles.append(node)
        }

        if let powerUpType = difficulty.powerUpToSpawnIfDue() {
            let node = PowerUpNode(type: powerUpType, groundY: groundY, laneHeight: 100)
            node.position.x = spawnX
            addChild(node)
            powerUps.append(node)
        }
    }

    // MARK: - Run end & HUD reporting

    private func endRun() {
        guard isRunActive else { return }
        isRunActive = false
        AudioManager.shared.playSFX(.gameOver)
        AudioManager.shared.stopMusic()
        stats.score = score
        stats.distanceMeters = Int(difficulty.distanceMeters)
        gameDelegate?.gameScene(self, didEndRunWith: stats)
    }

    private func reportHUD() {
        let hud = GameHUDState(
            score: score,
            coins: stats.coinsCollected,
            distanceMeters: Int(difficulty.distanceMeters),
            comboMeterFraction: combo.meter,
            isComboReady: combo.isReady,
            isComboActive: combo.isComboActive,
            isShielded: player.isShielded,
            isMagnetActive: player.isMagnetActive,
            currentWorld: difficulty.currentWorld
        )
        gameDelegate?.gameScene(self, didUpdate: hud)
    }
}
