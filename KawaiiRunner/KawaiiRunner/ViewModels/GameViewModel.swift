import SwiftUI
import Combine

/// A short-lived banner shown over the HUD when a Buddy Assist fires
/// (Team Lift, Buddy Block, Combo Move), so the player understands *why*
/// they just survived a hit.
struct AssistBanner: Identifiable, Equatable {
    let id = UUID()
    let text: String
}

/// Bridges `GameScene` (SpriteKit) to `GameView` (SwiftUI). Owns the scene
/// instance, republishes its HUD state as `@Published` properties, forwards
/// gesture input down into the scene, and — once a run ends — applies the
/// result via `EconomyManager` and exposes a `GameOverPayload` for
/// `GameOverView`.
@MainActor
final class GameViewModel: ObservableObject {
    let scene: GameScene

    @Published private(set) var hud = GameHUDState()
    @Published var isPaused = false
    @Published var gameOverPayload: GameOverPayload?
    @Published var assistBanner: AssistBanner?

    private let leadCharacter: CharacterType

    struct GameOverPayload: Identifiable {
        let id = UUID()
        let summary: RunSummary
        let isNewHighScore: Bool
        let newlyUnlockedAchievements: [Achievement]
    }

    init(leadCharacter: CharacterType) {
        self.leadCharacter = leadCharacter
        // `.resizeFill` makes SpriteKit resize the scene to match the
        // SpriteView's actual bounds on layout, so this initial size is just
        // a reasonable placeholder until then.
        let scene = GameScene()
        scene.size = CGSize(width: 393, height: 852)
        scene.scaleMode = .resizeFill
        self.scene = scene
        scene.gameDelegate = self
        scene.startNewRun(lead: leadCharacter)
    }

    func retry() {
        gameOverPayload = nil
        isPaused = false
        scene.startNewRun(lead: leadCharacter)
    }

    // MARK: - Input forwarding

    func onTap() { scene.handleTap() }
    func onDoubleTap() { scene.handleDoubleTap() }
    func onSwipeDown() { scene.handleSwipeDown() }
    func onLongPressBegan() { scene.handleLongPressBegan() }
    func onLongPressEnded() { scene.handleLongPressEnded() }
    func onComboButtonTapped() { scene.handleComboButtonTapped() }

    func togglePause() {
        isPaused.toggle()
        scene.setPaused(isPaused)
    }

    func showAssistBanner(_ text: String) {
        assistBanner = AssistBanner(text: text)
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            if assistBanner?.text == text { assistBanner = nil }
        }
    }
}

extension GameViewModel: GameSceneDelegate {
    nonisolated func gameScene(_ scene: GameScene, didUpdate hudState: GameHUDState) {
        Task { @MainActor in self.hud = hudState }
    }

    nonisolated func gameScene(_ scene: GameScene, didEndRunWith summary: RunSummary) {
        Task { @MainActor in
            let isNewHighScore = EconomyManager.shared.applyRunSummary(summary)
            GameCenterManager.shared.submit(score: summary.score)
            self.gameOverPayload = GameOverPayload(
                summary: summary,
                isNewHighScore: isNewHighScore,
                newlyUnlockedAchievements: AchievementManager.shared.lastUnlocked
            )
        }
    }

    nonisolated func gameSceneDidTriggerBuddyAssist(_ scene: GameScene, assist: BuddyAssist) {
        Task { @MainActor in self.showAssistBanner(assist.announcementText) }
    }
}
