import SwiftUI
import Combine

/// Drives the Missions screen's Daily/Weekly tabs.
@MainActor
final class MissionsViewModel: ObservableObject {
    enum Tab: Hashable { case daily, weekly }

    @Published var selectedTab: Tab = .daily
    @Published private(set) var profile: PlayerProfile

    private var cancellable: AnyCancellable?

    init() {
        profile = SaveManager.shared.profile
        cancellable = SaveManager.shared.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.profile = $0 }
        MissionManager.shared.refreshIfNeeded()
    }

    var visibleMissions: [Mission] {
        selectedTab == .daily ? profile.dailyMissions : profile.weeklyMissions
    }
}
