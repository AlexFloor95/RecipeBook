import Foundation

/// What a streak day rewards. Day 7 (and every 7th day after) is always the
/// big "Lucky Wheel" spin; other days grant a flat currency/XP bundle that
/// grows gently across the week to encourage returning daily.
enum DailyRewardKind: Codable, Hashable {
    case coins(Int)
    case cocoTokens(Int)
    case xp(Int)
    case luckyWheelSpin
}

struct DailyReward: Identifiable, Hashable {
    var id: Int { dayIndex }
    /// 1-based day within the current 7-day streak cycle.
    let dayIndex: Int
    let kind: DailyRewardKind

    static let sevenDayCycle: [DailyReward] = [
        DailyReward(dayIndex: 1, kind: .coins(30)),
        DailyReward(dayIndex: 2, kind: .coins(40)),
        DailyReward(dayIndex: 3, kind: .xp(30)),
        DailyReward(dayIndex: 4, kind: .coins(60)),
        DailyReward(dayIndex: 5, kind: .cocoTokens(2)),
        DailyReward(dayIndex: 6, kind: .coins(90)),
        DailyReward(dayIndex: 7, kind: .luckyWheelSpin),
    ]
}

/// A single prize slice on the Lucky Wheel, weighted by `weight` (higher =
/// more likely). Weights loosely follow a soft economy curve so big prizes
/// feel special without being frustratingly rare.
struct LuckyWheelPrize: Identifiable, Hashable {
    let id = UUID()
    let label: String
    let kind: DailyRewardKind
    let weight: Double
    let colorHex: String

    static let wheel: [LuckyWheelPrize] = [
        LuckyWheelPrize(label: "+50 Coins", kind: .coins(50), weight: 30, colorHex: "#FFB6D1"),
        LuckyWheelPrize(label: "+100 Coins", kind: .coins(100), weight: 20, colorHex: "#FF8FB1"),
        LuckyWheelPrize(label: "+20 XP", kind: .xp(20), weight: 20, colorHex: "#8FD3FF"),
        LuckyWheelPrize(label: "+1 Coco Token", kind: .cocoTokens(1), weight: 15, colorHex: "#C6A8FF"),
        LuckyWheelPrize(label: "+250 Coins", kind: .coins(250), weight: 8, colorHex: "#FFD97A"),
        LuckyWheelPrize(label: "+5 Coco Tokens", kind: .cocoTokens(5), weight: 5, colorHex: "#FF6F91"),
        LuckyWheelPrize(label: "+500 Coins", kind: .coins(500), weight: 2, colorHex: "#F4C542"),
    ]

    /// Weighted-random prize selection. Kept pure (takes randomness as an
    /// injectable generator) so it can be unit tested deterministically.
    static func spin(using generator: inout RandomNumberGenerator) -> LuckyWheelPrize {
        let total = wheel.reduce(0) { $0 + $1.weight }
        var roll = Double.random(in: 0..<total, using: &generator)
        for prize in wheel {
            if roll < prize.weight { return prize }
            roll -= prize.weight
        }
        return wheel.first!
    }
}
