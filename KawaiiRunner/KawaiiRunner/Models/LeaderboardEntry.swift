import Foundation

/// A single completed-run result. Used both for the always-available local
/// leaderboard (top 20 runs on this device, no network needed) and as the
/// payload submitted to Game Center when `GameCenterManager` is authenticated.
struct LeaderboardEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let score: Int
    let distanceMeters: Int
    let character: CharacterType
    let date: Date

    init(score: Int, distanceMeters: Int, character: CharacterType, date: Date) {
        self.id = UUID()
        self.score = score
        self.distanceMeters = distanceMeters
        self.character = character
        self.date = date
    }
}
