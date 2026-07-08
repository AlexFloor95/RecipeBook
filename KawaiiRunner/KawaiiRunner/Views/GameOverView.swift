import SwiftUI

/// Shown when a run ends: final score, rewards earned, an optional "new
/// high score" banner, any achievements unlocked this run, an optional
/// rewarded-ad path to double the run's coins, and Retry/Home actions.
struct GameOverView: View {
    let payload: GameViewModel.GameOverPayload
    let onRetry: () -> Void
    let onHome: () -> Void

    @State private var didWatchAdForDouble = false
    @State private var isWatchingAd = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [KawaiiPalette.lavender.opacity(0.4), KawaiiPalette.creamWhite], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    if payload.isNewHighScore {
                        Text("🎉 New High Score! 🎉")
                            .font(.system(.title3, design: .rounded)).bold()
                            .foregroundStyle(KawaiiPalette.mochiPink)
                    }

                    Text("\(payload.summary.score)")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundStyle(KawaiiPalette.textDark)
                    Text("points")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(KawaiiPalette.textDark.opacity(0.6))

                    statsCard

                    if !payload.newlyUnlockedAchievements.isEmpty {
                        achievementsCard
                    }

                    if !didWatchAdForDouble {
                        Button {
                            Task { await watchAdForDouble() }
                        } label: {
                            HStack {
                                Image(systemName: "play.rectangle.fill")
                                Text(isWatchingAd ? "Watching..." : "Watch Ad to Double Coins")
                                    .fontWeight(.bold)
                            }
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(KawaiiPalette.textDark)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(Capsule().fill(KawaiiPalette.honeyYellow))
                        }
                        .disabled(isWatchingAd)
                    }

                    VStack(spacing: 14) {
                        KawaiiButton(title: "Retry", systemImage: "arrow.counterclockwise", action: onRetry)
                        KawaiiButton(title: "Home", systemImage: "house.fill", emphasis: .secondary, action: onHome)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            if payload.isNewHighScore {
                AudioManager.shared.playSFX(.newHighScore)
            }
        }
    }

    private var statsCard: some View {
        HStack {
            statColumn(title: "Coins", value: "\(payload.summary.coinsCollected)", icon: "dollarsign.circle.fill")
            statColumn(title: "Distance", value: "\(payload.summary.distanceMeters)m", icon: "figure.run")
            statColumn(title: "XP", value: "\(payload.summary.xpEarned)", icon: "star.fill")
        }
        .padding()
        .kawaiiCard()
    }

    private func statColumn(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(KawaiiPalette.mochiPink)
            Text(value).font(.system(.headline, design: .rounded)).bold()
            Text(title).font(.system(.caption2, design: .rounded)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Achievements Unlocked")
                .font(.system(.subheadline, design: .rounded)).bold()
            ForEach(payload.newlyUnlockedAchievements) { achievement in
                HStack {
                    Image(systemName: "trophy.fill").foregroundStyle(KawaiiPalette.honeyYellow)
                    Text("\(achievement.tierName) — \(achievement.description)")
                        .font(.system(.caption, design: .rounded))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .kawaiiCard()
    }

    private func watchAdForDouble() async {
        isWatchingAd = true
        let bonus = await IAPManager.shared.watchAdToDoubleCoins(originalCoins: payload.summary.coinsCollected)
        if bonus > 0 {
            EconomyManager.shared.grant(.coins(bonus))
        }
        didWatchAdForDouble = true
        isWatchingAd = false
    }
}
