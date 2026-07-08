import Foundation
import CoreGraphics

/// Owns pacing: how fast the world scrolls, how often obstacles/collectibles
/// spawn, which world theme is active, and making sure obstacle patterns
/// stay fair (never two unavoidable hazards back-to-back).
///
/// Tuned for the brief's "easy to learn, hard to put down" 2-5 minute
/// session goal: difficulty ramps gently and continuously rather than in
/// hard jumps, and the six worlds rotate every 350m so a single run always
/// visits multiple settings.
final class DifficultyDirector {
    private(set) var distanceMeters: Double = 0
    private(set) var scrollSpeed: CGFloat = 360 // points/sec
    private var timeSinceLastObstacle: TimeInterval = 999
    private var timeSinceLastCollectible: TimeInterval = 999
    private var timeSinceLastPowerUp: TimeInterval = 999
    private var lastAvoidance: AvoidanceMethod?
    private let powerUpInterval: TimeInterval = 12.0

    private let maxScrollSpeed: CGFloat = 760
    private let speedRampPerMeter: CGFloat = 0.12

    var currentWorld: WorldTheme {
        let index = Int(distanceMeters / 350) % WorldTheme.runOrder.count
        return WorldTheme.runOrder[index]
    }

    /// Advances distance/speed bookkeeping. Call once per frame with the
    /// scene's delta time; returns the number of world-space points the
    /// ground/props should scroll this frame.
    @discardableResult
    func advance(deltaTime: TimeInterval) -> CGFloat {
        scrollSpeed = min(maxScrollSpeed, 360 + CGFloat(distanceMeters) * speedRampPerMeter)
        let delta = scrollSpeed * CGFloat(deltaTime)
        distanceMeters += Double(delta) / 40.0 // 40pt ~= 1m, tuned for on-screen scale
        timeSinceLastObstacle += deltaTime
        timeSinceLastCollectible += deltaTime
        timeSinceLastPowerUp += deltaTime
        return delta
    }

    /// Minimum gap between obstacles shrinks as speed increases but never
    /// drops below a reaction-time floor, keeping the game always fair.
    private var obstacleInterval: TimeInterval {
        max(0.9, 1.9 - distanceMeters / 1500)
    }

    private var collectibleInterval: TimeInterval {
        0.45
    }

    /// Returns a new obstacle type to spawn if it's time, biased toward the
    /// current world's `featuredObstacles`, and never repeating the same
    /// avoidance method twice in a row (e.g. never two slide-unders back to back).
    func obstacleToSpawnIfDue() -> ObstacleType? {
        guard timeSinceLastObstacle >= obstacleInterval else { return nil }
        let pool = ObstacleType.allCases.filter { $0.avoidance != lastAvoidance }
        let biasedPool = pool + currentWorld.featuredObstacles.filter { pool.contains($0) }
        guard let chosen = biasedPool.randomElement() else { return nil }
        timeSinceLastObstacle = 0
        lastAvoidance = chosen.avoidance
        return chosen
    }

    /// Returns a new collectible type to spawn if it's time, using weighted
    /// random selection biased toward the current world's featured pickups.
    func collectibleToSpawnIfDue() -> CollectibleType? {
        guard timeSinceLastCollectible >= collectibleInterval else { return nil }
        timeSinceLastCollectible = 0

        var pool = CollectibleType.allCases.map { ($0, $0.spawnWeight) }
        for featured in currentWorld.featuredCollectibles {
            pool.append((featured, featured.spawnWeight * 0.5))
        }
        let total = pool.reduce(0) { $0 + $1.1 }
        var roll = Double.random(in: 0..<total)
        for (type, weight) in pool {
            if roll < weight { return type }
            roll -= weight
        }
        return pool.first?.0
    }

    /// Returns a power-up type to spawn if it's time. Rare by design (Magnet
    /// and Shield are meant to feel like a lucky bonus, not a constant crutch).
    func powerUpToSpawnIfDue() -> PowerUpType? {
        guard timeSinceLastPowerUp >= powerUpInterval else { return nil }
        timeSinceLastPowerUp = 0
        return PowerUpType.allCases.randomElement()
    }

    func reset() {
        distanceMeters = 0
        scrollSpeed = 360
        timeSinceLastObstacle = 999
        timeSinceLastCollectible = 999
        timeSinceLastPowerUp = 5 // first power-up arrives a little sooner than 12s
        lastAvoidance = nil
    }
}
