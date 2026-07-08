import Foundation

/// The result of a single completed run, handed off from `GameScene` /
/// `GameViewModel` to `EconomyManager` for scoring, currency awards and
/// progress tracking once the run ends.
struct RunSummary {
    var score: Int = 0
    var coinsCollected: Int = 0
    var cocoTokensCollected: Int = 0
    var xpEarned: Int = 0
    var distanceMeters: Int = 0
    var character: CharacterType = .debbie
    var mochiCollected: Int = 0
    var bubbleTeaCollected: Int = 0
    var catPawsCollected: Int = 0
    var dashUses: Int = 0
    var doubleJumpUses: Int = 0
    var magnetActivations: Int = 0
    var comboMoveActivations: Int = 0
}

/// Applies the economic consequences of a finished run to `PlayerProfile`:
/// currency grants, XP/level, high score, run history, and lifetime stats
/// used by achievements. Deliberately has no gameplay-balance knowledge of
/// *why* the numbers are what they are — that all lives upstream in
/// `RunSummary` construction inside `GameScene`.
@MainActor
final class EconomyManager {
    static let shared = EconomyManager()
    private init() {}

    /// Applies a finished run's rewards to the profile, updates bests, and
    /// forwards progress to `MissionManager` / `AchievementManager`. Returns
    /// whether this run set a new high score (used to show a banner on the
    /// Game Over screen).
    @discardableResult
    func applyRunSummary(_ summary: RunSummary) -> Bool {
        var profile = SaveManager.shared.profile

        profile.coins += summary.coinsCollected
        profile.cocoTokens += summary.cocoTokensCollected
        profile.xp += summary.xpEarned
        profile.totalRunsPlayed += 1
        profile.lifetimeDistanceMeters += summary.distanceMeters
        profile.longestRunMeters = max(profile.longestRunMeters, summary.distanceMeters)

        let isNewHighScore = summary.score > profile.highScore
        profile.highScore = max(profile.highScore, summary.score)

        profile.leaderboard.append(LeaderboardEntry(
            score: summary.score,
            distanceMeters: summary.distanceMeters,
            character: summary.character,
            date: Date()
        ))
        profile.leaderboard.sort { $0.score > $1.score }
        if profile.leaderboard.count > 20 {
            profile.leaderboard.removeLast(profile.leaderboard.count - 20)
        }

        SaveManager.shared.profile = profile

        MissionManager.shared.reportRunSummary(summary)
        AchievementManager.shared.reportRunSummary(summary)
        SaveManager.shared.saveNow()

        return isNewHighScore
    }

    /// Attempts to buy a shop item, deducting currency only if the player can
    /// afford it. Returns `true` on success.
    @discardableResult
    func purchase(_ item: ShopItem) -> Bool {
        var profile = SaveManager.shared.profile
        guard !profile.unlockedShopItemIDs.contains(item.id) else { return false }

        switch item.currency {
        case .coins:
            guard profile.coins >= item.price else { return false }
            profile.coins -= item.price
        case .cocoTokens:
            guard profile.cocoTokens >= item.price else { return false }
            profile.cocoTokens -= item.price
        case .premium:
            // Premium items are unlocked via IAPManager's StoreKit flow, not here.
            return false
        }

        profile.unlockedShopItemIDs.insert(item.id)
        SaveManager.shared.profile = profile
        SaveManager.shared.scheduleSave()
        AudioManager.shared.playSFX(.purchase)
        return true
    }

    /// Equips an already-unlocked cosmetic into its category slot.
    func equip(_ item: ShopItem) {
        var profile = SaveManager.shared.profile
        guard profile.unlockedShopItemIDs.contains(item.id) else { return }
        profile.equippedItems[item.category] = item.id
        SaveManager.shared.profile = profile
        SaveManager.shared.scheduleSave()
    }

    /// Grants a `DailyRewardKind` (from streak rewards or the Lucky Wheel)
    /// straight to the profile.
    func grant(_ kind: DailyRewardKind) {
        var profile = SaveManager.shared.profile
        switch kind {
        case .coins(let amount): profile.coins += amount
        case .cocoTokens(let amount): profile.cocoTokens += amount
        case .xp(let amount): profile.xp += amount
        case .luckyWheelSpin: break // handled by presenting the wheel, not a direct grant
        }
        SaveManager.shared.profile = profile
        SaveManager.shared.scheduleSave()
    }
}
