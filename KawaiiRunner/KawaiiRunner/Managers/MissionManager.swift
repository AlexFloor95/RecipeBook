import Foundation

/// Generates, tracks and rewards Daily Missions, Weekly Challenges and the
/// login streak / Lucky Wheel. All state lives on `PlayerProfile`; this
/// manager just contains the rules for when to roll fresh missions and how
/// a `RunSummary` maps onto mission progress.
@MainActor
final class MissionManager {
    static let shared = MissionManager()
    private init() {}

    private var calendar: Calendar { Calendar.current }

    /// Call once on app foreground / home screen appear. Rolls fresh daily
    /// missions if it's a new day, fresh weekly ones if it's a new week, and
    /// advances (or resets) the login streak.
    func refreshIfNeeded() {
        var profile = SaveManager.shared.profile
        let now = Date()

        if profile.missionsGeneratedOn == nil || !calendar.isDateInToday(profile.missionsGeneratedOn!) {
            profile.dailyMissions = Array(Mission.dailyPool().shuffled().prefix(3))
            profile.missionsGeneratedOn = now
        }

        if profile.weeklyMissionsGeneratedOn == nil
            || calendar.component(.weekOfYear, from: profile.weeklyMissionsGeneratedOn!) != calendar.component(.weekOfYear, from: now) {
            profile.weeklyMissions = Array(Mission.weeklyPool().shuffled().prefix(3))
            profile.weeklyMissionsGeneratedOn = now
        }

        updateStreak(&profile, now: now)
        SaveManager.shared.profile = profile
        SaveManager.shared.scheduleSave()
    }

    /// Streak logic: claiming "today" when the last claim was "yesterday"
    /// advances the streak; any bigger gap resets it to day 1. The reward
    /// itself is claimed explicitly from the Daily Rewards screen via
    /// `claimTodayReward()` — this just keeps the day counter honest.
    private func updateStreak(_ profile: inout PlayerProfile, now: Date) {
        guard let last = profile.lastClaimedRewardDate else { return }
        if calendar.isDateInToday(last) { return }
        if !calendar.isDateInYesterday(last) {
            profile.currentStreakDay = 0
        }
    }

    /// Whether today's streak reward is still available to claim.
    var hasUnclaimedDailyReward: Bool {
        guard let last = SaveManager.shared.profile.lastClaimedRewardDate else { return true }
        return !calendar.isDateInToday(last)
    }

    /// Claims today's streak reward, advancing the 7-day cycle. Returns the
    /// reward granted so the UI can animate it.
    @discardableResult
    func claimTodayReward() -> DailyReward {
        var profile = SaveManager.shared.profile
        profile.currentStreakDay = (profile.currentStreakDay % 7) + 1
        profile.lastClaimedRewardDate = Date()
        let reward = DailyReward.sevenDayCycle[profile.currentStreakDay - 1]
        SaveManager.shared.profile = profile
        if case .luckyWheelSpin = reward.kind {
            // Wheel result is granted separately once spun in the UI.
        } else {
            EconomyManager.shared.grant(reward.kind)
        }
        SaveManager.shared.scheduleSave()
        return reward
    }

    // MARK: - Progress reporting

    /// Feeds a finished run's stats into every active mission, marking
    /// completed ones and granting rewards immediately (auto-claim keeps the
    /// loop frictionless for short 2-5 minute sessions).
    func reportRunSummary(_ summary: RunSummary) {
        var profile = SaveManager.shared.profile
        profile.dailyMissions = profile.dailyMissions.map { apply(summary, to: $0) }
        profile.weeklyMissions = profile.weeklyMissions.map { apply(summary, to: $0) }
        SaveManager.shared.profile = profile
        autoClaimCompleted()
    }

    private func apply(_ summary: RunSummary, to mission: Mission) -> Mission {
        guard !mission.isComplete else { return mission }
        var mission = mission
        switch mission.goal {
        case .collectMochi: mission.progressValue += summary.mochiCollected
        case .collectBubbleTea: mission.progressValue += summary.bubbleTeaCollected
        case .collectCatPaws: mission.progressValue += summary.catPawsCollected
        case .collectCocoTokens: mission.progressValue += summary.cocoTokensCollected
        case .runDistanceMeters: mission.progressValue += summary.distanceMeters
        case .useDash: mission.progressValue += summary.dashUses
        case .useDoubleJump: mission.progressValue += summary.doubleJumpUses
        case .activateMagnet: mission.progressValue += summary.magnetActivations
        case .activateComboMove: mission.progressValue += summary.comboMoveActivations
        case .playRuns: mission.progressValue += 1
        case .reachScore: mission.progressValue = max(mission.progressValue, summary.score)
        }
        return mission
    }

    /// Grants rewards for any mission that just became complete and hasn't
    /// been paid out yet, then flags it `rewardClaimed` so a later run never
    /// pays it out twice.
    private func autoClaimCompleted() {
        var profile = SaveManager.shared.profile

        func payOut(_ mission: inout Mission) {
            guard mission.isComplete, !mission.rewardClaimed else { return }
            profile.coins += mission.rewardCoins
            profile.cocoTokens += mission.rewardTokens
            profile.xp += mission.rewardXP
            mission.rewardClaimed = true
        }

        for index in profile.dailyMissions.indices { payOut(&profile.dailyMissions[index]) }
        for index in profile.weeklyMissions.indices { payOut(&profile.weeklyMissions[index]) }

        SaveManager.shared.profile = profile
        SaveManager.shared.scheduleSave()
    }
}
