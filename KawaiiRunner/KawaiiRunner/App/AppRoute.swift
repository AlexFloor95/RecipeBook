import Foundation

/// Every full-screen menu destination reachable from Home, used as the
/// `NavigationStack` path type in `RootView`. The Game itself is presented
/// separately via a full-screen cover since it needs its own dedicated
/// `GameViewModel` instance per run.
enum AppRoute: Hashable {
    case characterSelect
    case shop
    case inventory
    case missions
    case achievements
    case leaderboard
    case settings
    case dailyRewards
}
