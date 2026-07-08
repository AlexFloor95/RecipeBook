import SwiftUI

/// Lifetime achievement tree, grouped into Bronze/Silver/Gold families.
struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Achievements", onClose: { dismiss() })
            Text("\(viewModel.unlockedCount)/\(viewModel.totalCount) unlocked")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.bottom, 6)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.families) { family in
                        AchievementRow(family: family)
                    }
                }
                .padding()
            }
        }
        .kawaiiDecorativeBackdrop()
        .navigationBarHidden(true)
    }
}

private struct AchievementRow: View {
    let family: AchievementsViewModel.AchievementFamily

    var body: some View {
        let tier = family.activeTier
        HStack(spacing: 12) {
            Image(systemName: tier.isUnlocked ? "trophy.fill" : "trophy")
                .font(.title2)
                .foregroundStyle(tier.isUnlocked ? KawaiiPalette.honeyYellow : .secondary)
            VStack(alignment: .leading, spacing: 6) {
                Text("\(tier.tierName) — \(tier.description)")
                    .font(.system(.subheadline, design: .rounded)).bold()
                    .foregroundStyle(KawaiiPalette.textDark)
                ProgressBarView(fraction: tier.progressFraction, fillColor: KawaiiPalette.lavender, height: 8)
            }
            Spacer()
            Text("+\(tier.rewardCoins)")
                .font(.system(.caption, design: .rounded)).bold()
        }
        .padding()
        .kawaiiCard()
    }
}

#Preview {
    AchievementsView()
}
