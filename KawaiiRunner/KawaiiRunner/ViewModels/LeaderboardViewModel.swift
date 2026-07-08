import SwiftUI
import UIKit
import Combine

/// Drives the Leaderboard screen. Always shows the on-device top-20 list;
/// additionally offers a Game Center hand-off when the player is
/// authenticated, per `GameCenterManager`.
@MainActor
final class LeaderboardViewModel: ObservableObject {
    @Published private(set) var entries: [LeaderboardEntry] = []
    @Published private(set) var isGameCenterAvailable = false

    private var cancellable: AnyCancellable?

    init() {
        entries = SaveManager.shared.profile.leaderboard
        isGameCenterAvailable = GameCenterManager.shared.isAuthenticated
        cancellable = SaveManager.shared.$profile
            .map(\.leaderboard)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.entries = $0 }
    }

    func presentGameCenter(from viewController: UIViewController) {
        GameCenterManager.shared.presentLeaderboard(from: viewController)
    }
}
