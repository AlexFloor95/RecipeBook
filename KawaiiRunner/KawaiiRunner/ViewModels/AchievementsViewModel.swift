import SwiftUI
import Combine

/// Drives the Achievements screen, grouping the flat achievement list into
/// families (e.g. "Mochi Muncher" Bronze/Silver/Gold) so the UI can show one
/// row per family with its current tier highlighted.
@MainActor
final class AchievementsViewModel: ObservableObject {
    @Published private(set) var profile: PlayerProfile
    private var cancellable: AnyCancellable?

    init() {
        profile = SaveManager.shared.profile
        cancellable = SaveManager.shared.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.profile = $0 }
    }

    struct AchievementFamily: Identifiable {
        let id: String
        let tiers: [Achievement]
        /// The tier currently being worked toward (first non-unlocked one),
        /// or the final tier if everything is already unlocked.
        var activeTier: Achievement { tiers.first(where: { !$0.isUnlocked }) ?? tiers.last! }
    }

    var families: [AchievementFamily] {
        let liveTiers = Achievement.all.map { profile.achievements[$0.id] ?? $0 }
        let grouped = Dictionary(grouping: liveTiers, by: \.familyID)
        return grouped.map { AchievementFamily(id: $0.key, tiers: $0.value.sorted { $0.targetValue < $1.targetValue }) }
            .sorted { $0.id < $1.id }
    }

    var unlockedCount: Int { profile.achievements.values.filter(\.isUnlocked).count }
    var totalCount: Int { profile.achievements.count }
}
