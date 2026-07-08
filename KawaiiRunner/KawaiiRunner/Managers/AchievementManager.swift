import Foundation

/// Tracks lifetime achievement progress (never resets) and unlocks tiers as
/// cumulative totals are crossed. Unlike missions, achievement rewards are
/// coins-only and paid out the moment a tier unlocks.
@MainActor
final class AchievementManager {
    static let shared = AchievementManager()
    private init() {}

    /// Newly unlocked achievements from the most recent call to
    /// `reportRunSummary`, surfaced so the UI can show an unlock toast.
    private(set) var lastUnlocked: [Achievement] = []

    func reportRunSummary(_ summary: RunSummary) {
        var profile = SaveManager.shared.profile
        var newlyUnlocked: [Achievement] = []

        func increment(_ goal: MissionGoalType, by amount: Int) {
            guard amount != 0 else { return }
            for id in profile.achievements.keys where profile.achievements[id]?.goal == goal {
                guard var achievement = profile.achievements[id], !achievement.isUnlocked else { continue }
                achievement.progressValue += amount
                if achievement.progressValue >= achievement.targetValue {
                    achievement.progressValue = achievement.targetValue
                    achievement.unlockedDate = Date()
                    profile.coins += achievement.rewardCoins
                    newlyUnlocked.append(achievement)
                }
                profile.achievements[id] = achievement
            }
        }

        func setMax(_ goal: MissionGoalType, to value: Int) {
            for id in profile.achievements.keys where profile.achievements[id]?.goal == goal {
                guard var achievement = profile.achievements[id], !achievement.isUnlocked else { continue }
                achievement.progressValue = max(achievement.progressValue, value)
                if achievement.progressValue >= achievement.targetValue {
                    achievement.progressValue = achievement.targetValue
                    achievement.unlockedDate = Date()
                    profile.coins += achievement.rewardCoins
                    newlyUnlocked.append(achievement)
                }
                profile.achievements[id] = achievement
            }
        }

        increment(.collectMochi, by: summary.mochiCollected)
        increment(.collectBubbleTea, by: summary.bubbleTeaCollected)
        increment(.collectCatPaws, by: summary.catPawsCollected)
        increment(.collectCocoTokens, by: summary.cocoTokensCollected)
        increment(.runDistanceMeters, by: summary.distanceMeters)
        increment(.useDash, by: summary.dashUses)
        increment(.activateComboMove, by: summary.comboMoveActivations)
        increment(.playRuns, by: 1)
        setMax(.reachScore, to: summary.score)

        lastUnlocked = newlyUnlocked
        if !newlyUnlocked.isEmpty {
            AudioManager.shared.playSFX(.rewardUnlock)
        }
        SaveManager.shared.profile = profile
        SaveManager.shared.scheduleSave()
    }
}
