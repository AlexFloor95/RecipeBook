import Foundation

/// Live, per-frame gameplay state `GameScene` reports upward to
/// `GameViewModel` so the SwiftUI HUD can render score, currency, meters and
/// power-up indicators without polling the scene directly.
struct GameHUDState: Equatable {
    var score: Int = 0
    var coins: Int = 0
    var distanceMeters: Int = 0
    var comboMeterFraction: Double = 0
    var isComboReady: Bool = false
    var isComboActive: Bool = false
    var isShielded: Bool = false
    var isMagnetActive: Bool = false
    var currentWorld: WorldTheme = .mochiCafe
}

/// Callbacks from `GameScene` back to the SwiftUI/MVVM layer. Keeping this a
/// protocol (rather than reaching into `GameViewModel` directly) keeps the
/// SpriteKit layer testable and reusable outside SwiftUI if needed.
protocol GameSceneDelegate: AnyObject {
    func gameScene(_ scene: GameScene, didUpdate hudState: GameHUDState)
    func gameScene(_ scene: GameScene, didEndRunWith summary: RunSummary)
    func gameSceneDidTriggerBuddyAssist(_ scene: GameScene, assist: BuddyAssist)
}
