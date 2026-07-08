import SwiftUI
import Combine

/// Drives the Home screen: currency/level summary, selected character, and
/// whether a Daily Reward is waiting to be claimed. Reads its data straight
/// from `SaveManager.shared.profile` via a Combine subscription so the UI
/// always reflects the latest saved state without manual refresh calls.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var profile: PlayerProfile
    @Published private(set) var hasUnclaimedDailyReward: Bool = false

    private var cancellable: AnyCancellable?

    init() {
        profile = SaveManager.shared.profile
        cancellable = SaveManager.shared.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.profile = $0 }
        refresh()
    }

    /// Call on `.onAppear` so missions/streak roll over correctly if the app
    /// was left open (or reopened) across a day boundary.
    func refresh() {
        MissionManager.shared.refreshIfNeeded()
        hasUnclaimedDailyReward = MissionManager.shared.hasUnclaimedDailyReward
    }

    func selectLead(_ character: CharacterType) {
        var updated = SaveManager.shared.profile
        updated.selectedLeadCharacter = character
        SaveManager.shared.profile = updated
        SaveManager.shared.scheduleSave()
    }
}
