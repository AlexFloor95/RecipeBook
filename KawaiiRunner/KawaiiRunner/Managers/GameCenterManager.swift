import GameKit
import UIKit

/// Optional Game Center integration for global leaderboards & achievements.
/// The game is fully playable without ever authenticating — `LeaderboardView`
/// falls back to the on-device top-20 list from `PlayerProfile.leaderboard`
/// whenever Game Center isn't available or the player declines sign-in.
///
/// To activate: create a leaderboard in App Store Connect with the ID below
/// and enable the Game Center capability on the target.
@MainActor
final class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()

    /// Replace with the leaderboard ID configured in App Store Connect.
    static let highScoreLeaderboardID = "com.debbiealex.kawaiirunner.highscore"

    @Published private(set) var isAuthenticated = false

    private override init() { super.init() }

    /// Call once on app launch. Presents Apple's sign-in sheet via the
    /// returned view controller handler if the player isn't signed into
    /// Game Center yet; declining is a normal, fully-supported path.
    func authenticate(presentingHandler: @escaping (UIViewController) -> Void) {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            guard let self else { return }
            if let viewController {
                presentingHandler(viewController)
                return
            }
            self.isAuthenticated = (error == nil) && GKLocalPlayer.local.isAuthenticated
        }
    }

    /// Submits a run's score. Safe to call unconditionally — it silently
    /// no-ops when the player isn't authenticated.
    func submit(score: Int) {
        guard isAuthenticated else { return }
        Task {
            try? await GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [Self.highScoreLeaderboardID]
            )
        }
    }

    /// Presents Apple's native Game Center leaderboard UI.
    func presentLeaderboard(from presenter: UIViewController) {
        guard isAuthenticated else { return }
        let controller = GKGameCenterViewController(leaderboardID: Self.highScoreLeaderboardID, playerScope: .global, timeScope: .allTime)
        controller.gameCenterDelegate = self
        presenter.present(controller, animated: true)
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    nonisolated func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
