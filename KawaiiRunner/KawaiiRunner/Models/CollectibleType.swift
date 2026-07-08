import Foundation

/// Every pickup the duo can run into. Values tune the economy — keep them
/// small and frequent so a 2-5 minute run always feels rewarding.
enum CollectibleType: String, Codable, CaseIterable, Hashable {
    case mochi
    case bubbleTea
    case flower
    case heart
    case star
    case catPaw
    case cocoToken

    /// Coins granted to the run total when collected.
    var coinValue: Int {
        switch self {
        case .mochi: return 1
        case .bubbleTea: return 2
        case .flower: return 1
        case .heart: return 0
        case .star: return 0
        case .catPaw: return 3
        case .cocoToken: return 0
        }
    }

    /// XP granted toward the player's level.
    var xpValue: Int {
        switch self {
        case .mochi, .flower: return 1
        case .bubbleTea, .catPaw: return 2
        case .heart, .star: return 3
        case .cocoToken: return 10
        }
    }

    /// How much this pickup fills the shared Combo Meter (0...1 scale, meter caps at 1.0).
    var comboMeterContribution: Double {
        switch self {
        case .heart: return 0.12
        case .star: return 0.18
        default: return 0.0
        }
    }

    /// Coco Tokens are the premium soft currency used for rarer shop items.
    var cocoTokenValue: Int {
        self == .cocoToken ? 1 : 0
    }

    /// Relative spawn weight used by `DifficultyDirector` when picking the next
    /// pickup for a lane. Rarer/more valuable items should be weighted lower.
    var spawnWeight: Double {
        switch self {
        case .mochi: return 40
        case .bubbleTea: return 20
        case .flower: return 20
        case .heart: return 8
        case .star: return 6
        case .catPaw: return 10
        case .cocoToken: return 2
        }
    }

    /// Pastel tint used for the glossy backing circle and sparkle/particle
    /// color wherever this pickup is rendered, so a mochi always reads warm
    /// and a star always reads golden regardless of the active world palette.
    var accentHex: String {
        switch self {
        case .mochi: return "#FFD8E8"
        case .bubbleTea: return "#C9A27A"
        case .flower: return "#FF9EC4"
        case .heart: return "#FF6F91"
        case .star: return "#FFD166"
        case .catPaw: return "#FFB37A"
        case .cocoToken: return "#F4C542"
        }
    }

    var placeholderEmoji: String {
        switch self {
        case .mochi: return "🍡"
        case .bubbleTea: return "🧋"
        case .flower: return "🌸"
        case .heart: return "💖"
        case .star: return "⭐️"
        case .catPaw: return "🐾"
        case .cocoToken: return "🪙"
        }
    }

    var collectSoundEffect: SoundEffect {
        switch self {
        case .cocoToken: return .collectToken
        case .heart, .star: return .collectSparkle
        default: return .collectSoft
        }
    }
}
