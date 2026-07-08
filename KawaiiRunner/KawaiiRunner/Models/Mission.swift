import Foundation

/// What a mission asks the player to do. `progressValue` is read from the
/// run/session stats reported by `GameViewModel` at the end of a run (or,
/// for `.playRuns`, once per run).
enum MissionGoalType: String, Codable, Hashable {
    case collectMochi
    case collectBubbleTea
    case collectCatPaws
    case collectCocoTokens
    case runDistanceMeters
    case useDash
    case useDoubleJump
    case activateMagnet
    case activateComboMove
    case playRuns
    case reachScore
}

/// How often a mission resets. Daily missions refresh every midnight, weekly
/// ones every Monday; `MissionManager` owns the actual scheduling.
enum MissionPeriod: String, Codable, Hashable {
    case daily
    case weekly
}

/// A single tracked goal shown on the Missions screen with a reward attached.
struct Mission: Identifiable, Codable, Hashable {
    let id: String
    let period: MissionPeriod
    let goal: MissionGoalType
    let targetValue: Int
    var progressValue: Int = 0
    /// Set once the completion reward has been auto-granted, so
    /// `MissionManager` never pays out the same mission twice.
    var rewardClaimed: Bool = false
    let rewardCoins: Int
    let rewardTokens: Int
    let rewardXP: Int

    var isComplete: Bool { progressValue >= targetValue }
    var progressFraction: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, Double(progressValue) / Double(targetValue))
    }

    var title: String {
        switch goal {
        case .collectMochi: return "Collect \(targetValue) mochi 🍡"
        case .collectBubbleTea: return "Collect \(targetValue) bubble teas 🧋"
        case .collectCatPaws: return "Collect \(targetValue) cat paws 🐾"
        case .collectCocoTokens: return "Find \(targetValue) Coco Tokens 🪙"
        case .runDistanceMeters: return "Run \(targetValue)m in total 🏃"
        case .useDash: return "Dash \(targetValue) times 💨"
        case .useDoubleJump: return "Double jump \(targetValue) times ⬆️"
        case .activateMagnet: return "Activate Magnet \(targetValue) times 🧲"
        case .activateComboMove: return "Trigger \(targetValue) Combo Moves 💞"
        case .playRuns: return "Play \(targetValue) runs 🎮"
        case .reachScore: return "Score \(targetValue) points in one run 🏆"
        }
    }

    /// The full pool missions are randomly drawn from. `MissionManager` picks
    /// 3 daily + 3 weekly entries at rollover time, scaling weekly targets up.
    static func dailyPool() -> [Mission] {
        [
            Mission(id: "d_mochi", period: .daily, goal: .collectMochi, targetValue: 40, rewardCoins: 50, rewardTokens: 0, rewardXP: 20),
            Mission(id: "d_boba", period: .daily, goal: .collectBubbleTea, targetValue: 15, rewardCoins: 60, rewardTokens: 0, rewardXP: 20),
            Mission(id: "d_paws", period: .daily, goal: .collectCatPaws, targetValue: 10, rewardCoins: 40, rewardTokens: 0, rewardXP: 15),
            Mission(id: "d_distance", period: .daily, goal: .runDistanceMeters, targetValue: 800, rewardCoins: 70, rewardTokens: 0, rewardXP: 25),
            Mission(id: "d_dash", period: .daily, goal: .useDash, targetValue: 8, rewardCoins: 40, rewardTokens: 0, rewardXP: 15),
            Mission(id: "d_combo", period: .daily, goal: .activateComboMove, targetValue: 3, rewardCoins: 50, rewardTokens: 1, rewardXP: 30),
            Mission(id: "d_runs", period: .daily, goal: .playRuns, targetValue: 3, rewardCoins: 30, rewardTokens: 0, rewardXP: 10),
            Mission(id: "d_score", period: .daily, goal: .reachScore, targetValue: 1500, rewardCoins: 80, rewardTokens: 0, rewardXP: 30),
        ]
    }

    static func weeklyPool() -> [Mission] {
        [
            Mission(id: "w_mochi", period: .weekly, goal: .collectMochi, targetValue: 250, rewardCoins: 300, rewardTokens: 2, rewardXP: 120),
            Mission(id: "w_tokens", period: .weekly, goal: .collectCocoTokens, targetValue: 20, rewardCoins: 200, rewardTokens: 3, rewardXP: 100),
            Mission(id: "w_distance", period: .weekly, goal: .runDistanceMeters, targetValue: 6000, rewardCoins: 350, rewardTokens: 2, rewardXP: 150),
            Mission(id: "w_combo", period: .weekly, goal: .activateComboMove, targetValue: 20, rewardCoins: 250, rewardTokens: 3, rewardXP: 130),
            Mission(id: "w_runs", period: .weekly, goal: .playRuns, targetValue: 15, rewardCoins: 200, rewardTokens: 1, rewardXP: 80),
        ]
    }
}
