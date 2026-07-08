import SwiftUI
import Combine

/// Drives the Daily Rewards screen: the 7-day streak calendar plus the
/// Lucky Wheel that's unlocked every 7th day.
@MainActor
final class DailyRewardsViewModel: ObservableObject {
    @Published private(set) var profile: PlayerProfile
    @Published var lastSpinResult: LuckyWheelPrize?
    @Published var isShowingWheel = false

    private var cancellable: AnyCancellable?
    private var rng: RandomNumberGenerator = SystemRandomNumberGenerator()

    init() {
        profile = SaveManager.shared.profile
        cancellable = SaveManager.shared.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.profile = $0 }
    }

    var hasUnclaimedReward: Bool { MissionManager.shared.hasUnclaimedDailyReward }
    var currentStreakDay: Int { profile.currentStreakDay }

    /// Claims today's streak reward. If it's a Lucky Wheel day, presents the
    /// wheel instead of granting currency directly.
    func claimToday() {
        let reward = MissionManager.shared.claimTodayReward()
        if case .luckyWheelSpin = reward.kind {
            isShowingWheel = true
        }
    }

    /// Spins the wheel, grants the resulting prize, and returns it so
    /// `LuckyWheelView` can animate the wheel to land on the same result.
    @discardableResult
    func spinWheel() -> LuckyWheelPrize {
        let prize = LuckyWheelPrize.spin(using: &rng)
        EconomyManager.shared.grant(prize.kind)
        lastSpinResult = prize
        return prize
    }
}
