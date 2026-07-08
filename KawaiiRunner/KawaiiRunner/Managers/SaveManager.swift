import Foundation
import Combine

/// Owns the single `PlayerProfile` for the whole app and is responsible for
/// persisting it to disk. Everything else (views, view models, the game
/// scene) reads/writes through `SaveManager.shared.profile` — there is no
/// second source of truth.
///
/// Persistence strategy: a JSON file in the app's Documents directory. This
/// is simple, human-inspectable (handy while developing) and durable across
/// app updates. If cloud sync is added later, this is the seam to hook a
/// `NSUbiquitousKeyValueStore`/CloudKit mirror into.
@MainActor
final class SaveManager: ObservableObject {
    static let shared = SaveManager()

    /// The live, in-memory profile. Mutating this from anywhere immediately
    /// updates every SwiftUI view observing `SaveManager` and schedules a
    /// debounced autosave.
    @Published var profile: PlayerProfile

    private let fileURL: URL
    private var saveWorkItem: DispatchWorkItem?
    /// Current on-disk schema version, used to gate future migrations.
    private static let currentSchemaVersion = 1

    private init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("player_profile.json")
        profile = SaveManager.loadFromDisk(at: fileURL) ?? .newProfile
    }

    /// Loads and decodes the profile file if present and valid; returns nil
    /// (triggering a fresh profile) on first launch or if the file is corrupt.
    private static func loadFromDisk(at url: URL) -> PlayerProfile? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(PlayerProfile.self, from: data)
    }

    /// Persists `profile` to disk immediately. Prefer `scheduleSave()` for
    /// frequent small updates (e.g. mission progress ticking during a run).
    func saveNow() {
        saveWorkItem?.cancel()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(profile) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    /// Debounces disk writes by 0.6s so rapid-fire mutations (e.g. coins
    /// ticking up during a run) coalesce into a single write.
    func scheduleSave() {
        saveWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in self?.saveNow() }
        saveWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }

    /// Wipes progress and starts over. Used by the "Reset Progress" action in
    /// Settings, always behind a confirmation dialog in the UI layer.
    func resetProgress() {
        profile = .newProfile
        saveNow()
    }
}
