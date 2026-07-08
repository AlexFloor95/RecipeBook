import SwiftUI

/// The 7-day streak calendar. Day 7 always grants a Lucky Wheel spin,
/// presented as a sheet via `LuckyWheelView`.
struct DailyRewardsView: View {
    @StateObject private var viewModel = DailyRewardsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Daily Rewards", onClose: { dismiss() })

            Text("Streak Day \(viewModel.currentStreakDay == 0 ? 1 : viewModel.currentStreakDay)")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(KawaiiPalette.textDark)
                .padding(.top, 4)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(DailyReward.sevenDayCycle) { reward in
                    dayCell(reward)
                }
            }
            .padding()

            Spacer()

            KawaiiButton(
                title: viewModel.hasUnclaimedReward ? "Claim Today's Reward" : "Come Back Tomorrow",
                systemImage: "gift.fill"
            ) {
                viewModel.claimToday()
            }
            .disabled(!viewModel.hasUnclaimedReward)
            .opacity(viewModel.hasUnclaimedReward ? 1 : 0.5)
            .padding()
        }
        .background(KawaiiPalette.creamWhite.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $viewModel.isShowingWheel) {
            LuckyWheelView(viewModel: viewModel)
        }
    }

    private func dayCell(_ reward: DailyReward) -> some View {
        // The day about to be claimed: one past the current streak while a
        // reward is still waiting, otherwise the streak's current day itself.
        let upcomingDay = viewModel.hasUnclaimedReward ? (viewModel.currentStreakDay % 7) + 1 : viewModel.currentStreakDay
        let isPast = reward.dayIndex < viewModel.currentStreakDay
        let isToday = reward.dayIndex == upcomingDay
        return VStack(spacing: 6) {
            Text(reward.dayIndex == 7 ? "🎡" : icon(for: reward.kind))
                .font(.title2)
            Text("Day \(reward.dayIndex)")
                .font(.system(.caption2, design: .rounded)).bold()
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isPast ? KawaiiPalette.matchaGreen.opacity(0.4) : (isToday ? KawaiiPalette.mochiPink.opacity(0.3) : Color.white))
        )
    }

    private func icon(for kind: DailyRewardKind) -> String {
        switch kind {
        case .coins: return "🪙"
        case .cocoTokens: return "✨"
        case .xp: return "⭐️"
        case .luckyWheelSpin: return "🎡"
        }
    }
}

#Preview {
    DailyRewardsView()
}
