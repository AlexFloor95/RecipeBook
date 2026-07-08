import Foundation

/// A permanent, cumulative milestone (never resets, unlike Missions). Each
/// tier is a separate `Achievement` entry sharing a `familyID` so the UI can
/// group "Mochi Muncher I/II/III" together and show the next tier once the
/// current one is unlocked.
struct Achievement: Identifiable, Codable, Hashable {
    let id: String
    let familyID: String
    let tierName: String
    let goal: MissionGoalType
    let targetValue: Int
    let rewardCoins: Int
    var progressValue: Int = 0
    var unlockedDate: Date?

    var isUnlocked: Bool { unlockedDate != nil }
    var progressFraction: Double {
        guard targetValue > 0 else { return 0 }
        return min(1.0, Double(progressValue) / Double(targetValue))
    }

    var description: String {
        switch goal {
        case .collectMochi: return "Collect \(targetValue) mochi over your lifetime."
        case .collectBubbleTea: return "Collect \(targetValue) bubble teas over your lifetime."
        case .collectCatPaws: return "Collect \(targetValue) cat paws over your lifetime."
        case .collectCocoTokens: return "Collect \(targetValue) Coco Tokens over your lifetime."
        case .runDistanceMeters: return "Run a total of \(targetValue)m."
        case .useDash: return "Dash \(targetValue) times."
        case .useDoubleJump: return "Double jump \(targetValue) times."
        case .activateMagnet: return "Activate Magnet \(targetValue) times."
        case .activateComboMove: return "Trigger the Combo Move \(targetValue) times."
        case .playRuns: return "Complete \(targetValue) runs."
        case .reachScore: return "Reach a score of \(targetValue) in a single run."
        }
    }

    /// Full static achievement tree, three tiers per family.
    static let all: [Achievement] = {
        func family(_ id: String, _ goal: MissionGoalType, tiers: [(String, Int, Int)]) -> [Achievement] {
            tiers.map { tier in
                Achievement(id: "\(id)_\(tier.0)", familyID: id, tierName: tier.0, goal: goal, targetValue: tier.1, rewardCoins: tier.2)
            }
        }
        return family("mochi_muncher", .collectMochi, tiers: [("Bronze", 100, 50), ("Silver", 500, 150), ("Gold", 2000, 500)])
            + family("boba_buddy", .collectBubbleTea, tiers: [("Bronze", 50, 50), ("Silver", 250, 150), ("Gold", 1000, 500)])
            + family("paw_collector", .collectCatPaws, tiers: [("Bronze", 75, 50), ("Silver", 300, 150), ("Gold", 1200, 500)])
            + family("token_hunter", .collectCocoTokens, tiers: [("Bronze", 25, 100), ("Silver", 100, 300), ("Gold", 400, 900)])
            + family("marathoner", .runDistanceMeters, tiers: [("Bronze", 5000, 100), ("Silver", 25000, 350), ("Gold", 100000, 1000)])
            + family("dash_master", .useDash, tiers: [("Bronze", 50, 50), ("Silver", 250, 150), ("Gold", 1000, 500)])
            + family("dream_team", .activateComboMove, tiers: [("Bronze", 10, 100), ("Silver", 50, 300), ("Gold", 200, 900)])
            + family("regular", .playRuns, tiers: [("Bronze", 10, 50), ("Silver", 50, 150), ("Gold", 200, 500)])
            + family("high_scorer", .reachScore, tiers: [("Bronze", 1000, 100), ("Silver", 5000, 300), ("Gold", 20000, 900)])
    }()
}
