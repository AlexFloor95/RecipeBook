import SwiftUI

/// The navigation host for the whole app. `HomeView` is the permanent root;
/// every other menu screen pushes onto `path`, and the game itself is a
/// full-screen cover so it can own the whole screen (no nav bar, hidden
/// status bar, portrait-locked) independent of the menu stack underneath.
struct RootView: View {
    @State private var path = NavigationPath()
    @State private var isShowingGame = false
    @StateObject private var homeViewModel = HomeViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(viewModel: homeViewModel, path: $path, isShowingGame: $isShowingGame)
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .fullScreenCover(isPresented: $isShowingGame) {
            GameView(leadCharacter: homeViewModel.profile.selectedLeadCharacter)
        }
        .tint(KawaiiPalette.mochiPink)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .characterSelect:
            CharacterSelectView(viewModel: homeViewModel)
        case .shop:
            ShopView()
        case .inventory:
            InventoryView()
        case .missions:
            MissionsView()
        case .achievements:
            AchievementsView()
        case .leaderboard:
            LeaderboardView()
        case .settings:
            SettingsView()
        case .dailyRewards:
            DailyRewardsView()
        }
    }
}

#Preview {
    RootView()
}
