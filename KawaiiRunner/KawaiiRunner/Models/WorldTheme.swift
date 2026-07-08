import Foundation

/// One of the six kawaii settings the duo runs through. Worlds cycle in
/// order as the player's distance increases (`DifficultyDirector` swaps the
/// active theme roughly every 350m), then loop back to the first world at a
/// higher difficulty tier. Each world supplies its own palette, obstacle
/// pool bias and music/ambience suggestion so every stretch of a run feels
/// distinct even in short 2-5 minute sessions.
enum WorldTheme: String, Codable, CaseIterable, Identifiable, Hashable {
    case mochiCafe
    case sakuraPark
    case bubbleTeaStreet
    case cozyMarket
    case nightFestival
    case rooftopGarden

    var id: String { rawValue }

    /// Fixed cycle order the `DifficultyDirector` steps through as distance grows.
    static var runOrder: [WorldTheme] {
        [.mochiCafe, .sakuraPark, .bubbleTeaStreet, .cozyMarket, .nightFestival, .rooftopGarden]
    }

    var displayName: String {
        switch self {
        case .mochiCafe: return "Mochi Café"
        case .sakuraPark: return "Sakura Park"
        case .bubbleTeaStreet: return "Bubble Tea Street"
        case .cozyMarket: return "Cozy Market"
        case .nightFestival: return "Night Festival"
        case .rooftopGarden: return "Rooftop Garden"
        }
    }

    /// Hex colors for sky/background, mid-ground props and ground/ui accent.
    /// Kept as plain hex so both SwiftUI (`Color(hex:)`) and SpriteKit
    /// (`SKColor(hex:)`) can share one source of truth.
    var skyHex: String {
        switch self {
        case .mochiCafe: return "#FFE8D6"
        case .sakuraPark: return "#FFE0EC"
        case .bubbleTeaStreet: return "#E4D9FF"
        case .cozyMarket: return "#FFF3C4"
        case .nightFestival: return "#2C2A4A"
        case .rooftopGarden: return "#DFF6E4"
        }
    }

    /// Zenith (top-of-sky) color, paired with `skyHex` as the horizon color
    /// to render a two-tone gradient sky instead of a flat fill.
    var skyTopHex: String {
        switch self {
        case .mochiCafe: return "#FFF6E9"
        case .sakuraPark: return "#FFF3F8"
        case .bubbleTeaStreet: return "#EFE8FF"
        case .cozyMarket: return "#FFFBE0"
        case .nightFestival: return "#0F0E28"
        case .rooftopGarden: return "#F3FFF5"
        }
    }

    /// Only the Night Festival trades the sun for a moon.
    var isNight: Bool { self == .nightFestival }

    /// Color of the sun/moon disc drawn in the sky layer.
    var celestialHex: String {
        isNight ? "#F5F0DC" : "#FFE9A8"
    }

    var midgroundHex: String {
        switch self {
        case .mochiCafe: return "#F6B99A"
        case .sakuraPark: return "#FFB6D1"
        case .bubbleTeaStreet: return "#C6A8FF"
        case .cozyMarket: return "#FFD97A"
        case .nightFestival: return "#5B4E97"
        case .rooftopGarden: return "#9FE0AE"
        }
    }

    var groundHex: String {
        switch self {
        case .mochiCafe: return "#E8956E"
        case .sakuraPark: return "#F98FB3"
        case .bubbleTeaStreet: return "#9C7BE0"
        case .cozyMarket: return "#F2B84B"
        case .nightFestival: return "#3E3568"
        case .rooftopGarden: return "#6FBF7F"
        }
    }

    var accentHex: String {
        switch self {
        case .mochiCafe: return "#FF6F91"
        case .sakuraPark: return "#FF4F81"
        case .bubbleTeaStreet: return "#7C4DFF"
        case .cozyMarket: return "#FF8A3D"
        case .nightFestival: return "#FFD166"
        case .rooftopGarden: return "#2ECC71"
        }
    }

    /// Suggested looping background music track (see AUDIO_GUIDE.md for style notes).
    var musicTrackName: String {
        "music_\(rawValue)"
    }

    /// Suggested looping ambience bed layered under the music (cafe chatter, birds, etc).
    var ambienceTrackName: String {
        "ambience_\(rawValue)"
    }

    /// One-line creative direction for composers/sound designers.
    var musicMoodDescription: String {
        switch self {
        case .mochiCafe: return "Warm lo-fi hip-hop with soft vinyl crackle and marimba."
        case .sakuraPark: return "Airy lo-fi with koto plucks and gentle wind chimes."
        case .bubbleTeaStreet: return "Upbeat lo-fi with tapioca-pearl percussion and synth bass."
        case .cozyMarket: return "Acoustic guitar lo-fi with light hand-clap percussion."
        case .nightFestival: return "Dreamy lo-fi city-pop with distant taiko drums and lanterns synths."
        case .rooftopGarden: return "Chill lo-fi with rain-stick shakers and soft flute."
        }
    }

    /// Obstacle types that appear more frequently in this world (flavour bias
    /// only — `DifficultyDirector` still mixes in the full roster for variety).
    var featuredObstacles: [ObstacleType] {
        switch self {
        case .mochiCafe: return [.spilledDrink, .sleepyCat, .trafficCone]
        case .sakuraPark: return [.sleepyCat, .puddle, .angryCrow]
        case .bubbleTeaStreet: return [.spilledDrink, .fallingBox, .trafficCone]
        case .cozyMarket: return [.fallingBox, .trafficCone, .puddle]
        case .nightFestival: return [.angryCrow, .fallingBox, .spilledDrink]
        case .rooftopGarden: return [.puddle, .sleepyCat, .angryCrow]
        }
    }

    /// Collectible types that appear more frequently in this world.
    var featuredCollectibles: [CollectibleType] {
        switch self {
        case .mochiCafe: return [.mochi, .bubbleTea]
        case .sakuraPark: return [.flower, .heart]
        case .bubbleTeaStreet: return [.bubbleTea, .star]
        case .cozyMarket: return [.mochi, .catPaw]
        case .nightFestival: return [.star, .cocoToken]
        case .rooftopGarden: return [.flower, .catPaw]
        }
    }

    /// Total distance (in meters) that must be reached to unlock this world's
    /// entry in the world showcase / lookbook (worlds are always played in
    /// rotation regardless, this only gates cosmetic "world unlocked" fanfare).
    var unlockDistanceMeters: Double {
        Double(WorldTheme.runOrder.firstIndex(of: self) ?? 0) * 350
    }
}
