import SpriteKit
import UIKit

/// Pre-configured `SKEmitterNode` builders for every particle moment in the
/// game. Centralising these keeps `GameScene` readable and makes it trivial
/// to re-tune "feel" (particle counts, speeds, lifetimes) in one place.
enum ParticleFactory {

    /// A quick burst when a collectible is picked up.
    static func collectSparkle(color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.star(color: color)
        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 10
        emitter.particleLifetime = 0.5
        emitter.particleLifetimeRange = 0.2
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.3
        emitter.particleScaleSpeed = -0.8
        emitter.particleSpeed = 90
        emitter.particleSpeedRange = 40
        emitter.emissionAngleRange = .pi * 2
        emitter.particleAlpha = 1
        emitter.particleAlphaSpeed = -1.6
        emitter.particleRotationRange = .pi
        emitter.particleRotationSpeed = 2
        emitter.name = "fx_collectSparkle"
        return emitter
    }

    /// Small puff of dust under the player's feet on landing/dashing.
    static func dustPuff() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.softDot(color: .white)
        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 6
        emitter.particleLifetime = 0.35
        emitter.particleScale = 0.6
        emitter.particleScaleSpeed = -1.2
        emitter.particleSpeed = 40
        emitter.particleSpeedRange = 20
        emitter.emissionAngleRange = .pi
        emitter.emissionAngle = .pi
        emitter.particleAlpha = 0.6
        emitter.particleAlphaSpeed = -1.5
        emitter.name = "fx_dustPuff"
        return emitter
    }

    /// Continuous trail attached behind the player while dashing.
    static func dashTrail(color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.softDot(color: color, diameter: 30)
        emitter.particleBirthRate = 60
        emitter.particleLifetime = 0.3
        emitter.particleScale = 0.8
        emitter.particleScaleSpeed = -2.0
        emitter.particleAlpha = 0.7
        emitter.particleAlphaSpeed = -2.2
        emitter.particlePositionRange = CGVector(dx: 6, dy: 20)
        emitter.name = "fx_dashTrail"
        return emitter
    }

    /// Big celebratory confetti burst for the Team Combo Move.
    static func comboBurst() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.confettiChip(color: .white)
        emitter.particleColorSequence = nil
        emitter.particleColorBlendFactor = 1
        emitter.particleColor = .white
        emitter.particleBirthRate = 0
        emitter.numParticlesToEmit = 40
        emitter.particleLifetime = 1.0
        emitter.particleLifetimeRange = 0.4
        emitter.particleSpeed = 160
        emitter.particleSpeedRange = 80
        emitter.emissionAngleRange = .pi * 2
        emitter.yAcceleration = -220
        emitter.particleRotationSpeed = 4
        emitter.particleAlpha = 1
        emitter.particleAlphaSpeed = -1.0
        // Randomised kawaii confetti palette applied per-particle via a color sequence.
        let colors: [UIColor] = [
            UIColor(hex: "#FF8FB1"), UIColor(hex: "#8FD3FF"), UIColor(hex: "#FFD97A"), UIColor(hex: "#C6A8FF"),
        ]
        emitter.particleColorSequence = SKKeyframeSequence(keyframeValues: colors, times: [0, 0.33, 0.66, 1.0])
        emitter.name = "fx_comboBurst"
        return emitter
    }

    /// Ripple/shimmer shown while the Shield power-up is active.
    static func shieldAura(color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.softDot(color: color, diameter: 40)
        emitter.particleBirthRate = 12
        emitter.particleLifetime = 0.6
        emitter.particleScale = 1.0
        emitter.particleScaleSpeed = 0.6
        emitter.particleAlpha = 0.35
        emitter.particleAlphaSpeed = -0.6
        emitter.name = "fx_shieldAura"
        return emitter
    }

    /// Sparkling attraction lines shown while Magnet is active.
    static func magnetSparkle(color: UIColor) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = ParticleTextureFactory.softDot(color: color, diameter: 16)
        emitter.particleBirthRate = 20
        emitter.particleLifetime = 0.4
        emitter.particleScale = 0.5
        emitter.particleScaleSpeed = -1.0
        emitter.particleSpeed = 30
        emitter.emissionAngleRange = .pi * 2
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -2.0
        emitter.name = "fx_magnetSparkle"
        return emitter
    }

    /// Fires a one-shot emitter, then removes it from the scene once its
    /// particle lifetime has fully elapsed so emitters don't pile up.
    static func fireAndForget(_ emitter: SKEmitterNode, at position: CGPoint, in scene: SKNode) {
        emitter.position = position
        emitter.particleBirthRate = emitter.particleBirthRate == 0 ? 1000 : emitter.particleBirthRate
        scene.addChild(emitter)
        let totalLifetime = emitter.particleLifetime + emitter.particleLifetimeRange
        emitter.run(.sequence([.wait(forDuration: TimeInterval(totalLifetime) + 0.2), .removeFromParent()]))
    }
}
