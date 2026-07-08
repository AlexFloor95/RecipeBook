import Foundation
import CoreGraphics

/// The two activatable power-ups from the brief, distinct from ordinary
/// collectibles: rarer pickups that grant a temporary (Magnet) or
/// single-use (Shield) survival boost once picked up.
enum PowerUpType: String, Codable, CaseIterable, Hashable {
    case magnet
    case shield

    /// How long the effect lasts once picked up. Shield instead lasts until
    /// it absorbs one hit (or this ceiling elapses, whichever comes first).
    var duration: TimeInterval {
        switch self {
        case .magnet: return 6.0
        case .shield: return 14.0
        }
    }

    /// Radius (in points) within which Magnet pulls collectibles toward the player.
    var magnetRadius: CGFloat { 220 }

    var placeholderEmoji: String {
        switch self {
        case .magnet: return "🧲"
        case .shield: return "🛡️"
        }
    }

    /// Spawn is intentionally much rarer than ordinary collectibles.
    var spawnWeight: Double {
        switch self {
        case .magnet: return 3
        case .shield: return 2
        }
    }

    var activateSoundEffect: SoundEffect {
        self == .magnet ? .magnetActivate : .shieldActivate
    }
}
