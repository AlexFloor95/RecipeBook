import Foundation

/// Persisted audio/haptics preferences. Kept as its own small struct so
/// `SettingsView` can bind to it directly.
struct GameSettings: Codable, Equatable {
    var musicVolume: Double = 0.7
    var sfxVolume: Double = 1.0
    var hapticsEnabled: Bool = true
    var reduceMotion: Bool = false
}

/// The single Codable root object that represents "everything about this
/// player" — currencies, unlocks, equipped cosmetics, XP/level, streak state,
/// achievement & mission progress, past run history and settings.
///
/// `SaveManager` is the only thing that reads/writes this to disk; every
/// other system mutates a copy in memory (usually via `EconomyManager`,
/// `AchievementManager` or `MissionManager`) and then asks `SaveManager` to
/// persist it. Keeping one root struct makes save/load, migration and iCloud
/// sync (future work) straightforward.
struct PlayerProfile: Codable, Equatable {
    // MARK: Identity & currencies
    var playerName: String = "Player"
    var coins: Int = 0
    var cocoTokens: Int = 0
    var xp: Int = 0

    // MARK: Character & cosmetics
    var selectedLeadCharacter: CharacterType = .debbie
    var unlockedShopItemIDs: Set<String> = []
    /// Currently equipped item id per category (nil = none equipped).
    var equippedItems: [ShopItemCategory: String] = [:]

    // MARK: Progress trackers
    var achievements: [String: Achievement] = Achievement.all.reduce(into: [:]) { $0[$1.id] = $1 }
    var dailyMissions: [Mission] = []
    var weeklyMissions: [Mission] = []
    var missionsGeneratedOn: Date?
    var weeklyMissionsGeneratedOn: Date?

    // MARK: Streak & daily rewards
    var currentStreakDay: Int = 0
    var lastClaimedRewardDate: Date?
    var lastLuckyWheelSpinDate: Date?

    // MARK: Run history & bests
    var highScore: Int = 0
    var longestRunMeters: Int = 0
    var totalRunsPlayed: Int = 0
    var lifetimeDistanceMeters: Int = 0
    var leaderboard: [LeaderboardEntry] = []

    // MARK: Settings
    var settings: GameSettings = GameSettings()

    // MARK: Derived stats

    /// Simple level curve: level *n* requires `n * 100` cumulative XP.
    var level: Int {
        var lvl = 1
        var remaining = xp
        while remaining >= lvl * 100 {
            remaining -= lvl * 100
            lvl += 1
        }
        return lvl
    }

    /// XP progress (0...1) toward the next level, for progress bars.
    var levelProgressFraction: Double {
        var remaining = xp
        var lvl = 1
        while remaining >= lvl * 100 {
            remaining -= lvl * 100
            lvl += 1
        }
        return Double(remaining) / Double(lvl * 100)
    }

    /// A default, fresh profile — used on first launch and after "reset progress".
    static var newProfile: PlayerProfile {
        PlayerProfile(unlockedShopItemIDs: [])
    }
}
