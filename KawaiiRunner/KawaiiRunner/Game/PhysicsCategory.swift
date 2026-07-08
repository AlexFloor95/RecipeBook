import Foundation

/// Bitmask categories for SpriteKit's physics contact system. Kept as a
/// plain enum of `UInt32` rather than an `OptionSet` because nodes only ever
/// belong to exactly one category, while `contactTestBitMask` combines
/// several with a simple bitwise OR.
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let obstacle: UInt32 = 1 << 1
    static let collectible: UInt32 = 1 << 2
    static let ground: UInt32 = 1 << 3
}
