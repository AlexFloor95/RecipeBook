import Foundation

/// The two heroes of Mochi Dash. The player always controls both at once —
/// one is the "active" runner up front, the other is the "buddy" who performs
/// assist actions (see `BuddyAssist`). Players can swap who leads from the
/// Character Select screen; the buddy still follows and still helps.
enum CharacterType: String, Codable, CaseIterable, Identifiable, Hashable {
    case debbie
    case alex

    var id: String { rawValue }

    /// Display name shown throughout the UI.
    var displayName: String {
        switch self {
        case .debbie: return "Debbie"
        case .alex: return "Alex"
        }
    }

    /// Short flavour text for the Character Select screen.
    var tagline: String {
        switch self {
        case .debbie: return "Bubble tea connoisseur & mochi-jump specialist 🧋"
        case .alex: return "Café regular with the world's best cat instincts 🐾"
        }
    }

    /// Name of the SpriteKit texture atlas / node prefix used for this
    /// character's animation frames (idle, run, jump, slide, dash, hurt).
    /// Real art can be dropped into Assets.xcassets using this prefix.
    var spriteBaseName: String {
        switch self {
        case .debbie: return "char_debbie"
        case .alex: return "char_alex"
        }
    }

    /// The other character, used whenever we need to resolve "the buddy".
    var partner: CharacterType {
        switch self {
        case .debbie: return .alex
        case .alex: return .debbie
        }
    }

    /// Base tint used for procedurally drawn placeholder art and UI accents.
    var themeColorHex: String {
        switch self {
        case .debbie: return "#FF8FB1" // sakura pink
        case .alex: return "#8FD3FF"   // sky blue
        }
    }
}
