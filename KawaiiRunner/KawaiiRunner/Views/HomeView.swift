import SwiftUI

/// The main menu: currency header, hero preview of the current duo, the big
/// Play button, and a grid of shortcuts into every other feature screen.
struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var path: NavigationPath
    @Binding var isShowingGame: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [KawaiiPalette.creamWhite, KawaiiPalette.mochiPink.opacity(0.25)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    header
                    heroPreview
                    playButton
                    shortcutGrid
                }
                .padding()
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.refresh() }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mochi Dash")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                    .foregroundStyle(KawaiiPalette.textDark)
                Text("Level \(viewModel.profile.level) • \(viewModel.profile.selectedLeadCharacter.displayName) & \(viewModel.profile.selectedLeadCharacter.partner.displayName)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(KawaiiPalette.textDark.opacity(0.6))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 6) {
                CurrencyBadge(systemImage: "dollarsign.circle.fill", value: viewModel.profile.coins)
                CurrencyBadge(systemImage: "sparkles", value: viewModel.profile.cocoTokens, tint: KawaiiPalette.lavender)
            }
        }
    }

    private var heroPreview: some View {
        HStack(spacing: 16) {
            ForEach(CharacterType.allCases) { character in
                VStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: character.themeColorHex).gradient)
                        .frame(width: 84, height: 84)
                        .overlay(Text(character == .debbie ? "🌸" : "🐾").font(.system(size: 34)))
                        .kawaiiOutline(color: character == viewModel.profile.selectedLeadCharacter ? KawaiiPalette.honeyYellow : .clear, lineWidth: 4, cornerRadius: 42)
                    Text(character.displayName)
                        .font(.system(.caption, design: .rounded)).bold()
                        .foregroundStyle(KawaiiPalette.textDark)
                }
            }
            Spacer()
            Button {
                path.append(AppRoute.characterSelect)
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "person.2.fill")
                    Text("Select")
                        .font(.system(.caption2, design: .rounded))
                }
                .foregroundStyle(KawaiiPalette.textDark)
            }
        }
        .padding()
        .kawaiiCard()
    }

    private var playButton: some View {
        KawaiiButton(title: "Play", systemImage: "play.fill") {
            isShowingGame = true
        }
        .padding(.vertical, 4)
    }

    private var shortcutGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            shortcut("Shop", "cart.fill", .shop)
            shortcut("Inventory", "bag.fill", .inventory)
            shortcut("Daily Rewards", "gift.fill", .dailyRewards, badge: viewModel.hasUnclaimedDailyReward)
            shortcut("Missions", "checklist", .missions)
            shortcut("Achievements", "trophy.fill", .achievements)
            shortcut("Leaderboard", "list.number", .leaderboard)
            shortcut("Settings", "gearshape.fill", .settings)
        }
    }

    private func shortcut(_ title: String, _ icon: String, _ route: AppRoute, badge: Bool = false) -> some View {
        Button {
            path.append(route)
        } label: {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(KawaiiPalette.mochiPink)
                    if badge {
                        Circle().fill(Color.red).frame(width: 10, height: 10).offset(x: 6, y: -4)
                    }
                }
                Text(title)
                    .font(.system(.caption, design: .rounded)).bold()
                    .foregroundStyle(KawaiiPalette.textDark)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .kawaiiCard()
        }
        .buttonStyle(.bouncy)
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(), path: .constant(NavigationPath()), isShowingGame: .constant(false))
    }
}
