import Foundation

/// Tracks the shared "Combo Meter" that Hearts and Stars fill up. Once full,
/// the player can trigger the Team Combo Move for a few seconds of full
/// invincibility and a score multiplier — the marquee cooperative feature
/// from the design brief.
final class ComboSystem {
    /// 0...1. Reaching 1.0 makes the combo move available.
    private(set) var meter: Double = 0
    private(set) var isComboActive = false
    private(set) var scoreMultiplier: Double = 1.0

    private var remainingActiveTime: TimeInterval = 0

    var isReady: Bool { meter >= 1.0 && !isComboActive }

    /// Called whenever a heart/star is collected.
    func addCharge(_ amount: Double) {
        guard !isComboActive else { return }
        meter = min(1.0, meter + amount)
    }

    /// Attempts to trigger the combo. Returns `true` if it actually started.
    @discardableResult
    func activate(duration: TimeInterval, multiplier: Double = 2.0) -> Bool {
        guard isReady else { return false }
        meter = 0
        isComboActive = true
        scoreMultiplier = multiplier
        remainingActiveTime = duration
        return true
    }

    /// Advances the combo's active-time countdown; call once per frame from
    /// `GameScene.update(_:)`. Returns `true` the exact frame the combo ends,
    /// so the caller can play an end-of-combo cue.
    @discardableResult
    func tick(deltaTime: TimeInterval) -> Bool {
        guard isComboActive else { return false }
        remainingActiveTime -= deltaTime
        if remainingActiveTime <= 0 {
            isComboActive = false
            scoreMultiplier = 1.0
            return true
        }
        return false
    }

    func reset() {
        meter = 0
        isComboActive = false
        scoreMultiplier = 1.0
        remainingActiveTime = 0
    }
}
