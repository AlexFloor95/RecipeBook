import Foundation

/// The cooperative moves Debbie & Alex can perform on each other. This is the
/// "unique feature" from the design brief: the duo helps each other survive.
///
/// - `lift`: The buddy lifts the runner over a tall obstacle instead of requiring
///   a manual jump (triggered automatically when an obstacle tagged `.needsLift`
///   is close and the lift is off cooldown).
/// - `shieldBlock`: The buddy steps in front and absorbs one hit for free.
/// - `comboMove`: Both characters combine for a few seconds of full invincibility
///   plus a score multiplier, once the shared Combo Meter (filled by collecting
///   hearts & stars) is full and the player taps the Combo button.
enum BuddyAssist: String, Codable, Hashable {
    case lift
    case shieldBlock
    case comboMove

    /// Cooldown before this assist can trigger again, in seconds.
    var cooldown: TimeInterval {
        switch self {
        case .lift: return 6
        case .shieldBlock: return 10
        case .comboMove: return 0 // gated by meter, not a timer
        }
    }

    /// Duration the effect lasts once activated.
    var duration: TimeInterval {
        switch self {
        case .lift: return 0.6
        case .shieldBlock: return 0.4
        case .comboMove: return 4.0
        }
    }

    var announcementText: String {
        switch self {
        case .lift: return "Team Lift!"
        case .shieldBlock: return "Buddy Block!"
        case .comboMove: return "COMBO TIME!"
        }
    }
}
