import Foundation
import CoreGraphics

/// The way a player must avoid a given obstacle. Used by `DifficultyDirector`
/// to make sure spawned obstacles are always fair (never two "jump" obstacles
/// back-to-back at a speed the player can't react to, etc).
enum AvoidanceMethod: Hashable {
    /// Obstacle sits on the ground — jump (or double jump for tall ones) over it.
    case jumpOver
    /// Obstacle hangs at head height — slide underneath it.
    case slideUnder
    /// Obstacle fills the whole lane — only a Dash (temporary invincible burst)
    /// or an active Shield gets you through safely.
    case dashOrShield
}

/// Hazards that appear across the six worlds. Every obstacle has a cute,
/// non-threatening design per the kawaii brief — even "angry" crows are drawn
/// with big round eyes rather than anything scary.
enum ObstacleType: String, Codable, CaseIterable, Hashable {
    case spilledDrink   // ground puddle-like splat, low profile
    case puddle         // ground, low profile
    case angryCrow      // flies at head height
    case fallingBox     // ground, tall — needs a jump or double jump
    case sleepyCat      // curled up on the ground, wide — needs a slide? no, jump (cute, sleeping)
    case trafficCone    // ground, medium height

    var avoidance: AvoidanceMethod {
        switch self {
        case .spilledDrink, .puddle: return .jumpOver
        case .angryCrow: return .slideUnder
        case .fallingBox: return .dashOrShield
        case .sleepyCat: return .jumpOver
        case .trafficCone: return .jumpOver
        }
    }

    /// Relative footprint used for spacing/collision sizing.
    var width: CGFloat {
        switch self {
        case .spilledDrink, .puddle: return 70
        case .angryCrow: return 60
        case .fallingBox: return 80
        case .sleepyCat: return 90
        case .trafficCone: return 40
        }
    }

    var height: CGFloat {
        switch self {
        case .spilledDrink, .puddle: return 20
        case .angryCrow: return 50
        case .fallingBox: return 110
        case .sleepyCat: return 45
        case .trafficCone: return 60
        }
    }

    var placeholderEmoji: String {
        switch self {
        case .spilledDrink: return "🥤"
        case .puddle: return "💦"
        case .angryCrow: return "🐦‍⬛"
        case .fallingBox: return "📦"
        case .sleepyCat: return "😴"
        case .trafficCone: return "🚧"
        }
    }

    var hitSoundEffect: SoundEffect { .obstacleHit }
}
