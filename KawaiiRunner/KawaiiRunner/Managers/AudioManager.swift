import AVFoundation

/// Central audio hub for music, ambience and one-shot sound effects.
///
/// No audio assets ship in this scaffold (see `Resources/Audio/AUDIO_GUIDE.md`
/// for concrete suggestions). All lookups fail gracefully — if a named
/// resource isn't bundled yet, playback calls are silently skipped so the
/// game runs perfectly well without art or audio in place while both are
/// being produced.
@MainActor
final class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var musicPlayer: AVAudioPlayer?
    private var ambiencePlayer: AVAudioPlayer?
    /// Small pool of players so overlapping SFX (e.g. two rapid collects)
    /// don't cut each other off.
    private var sfxPlayers: [AVAudioPlayer] = []
    private let sfxPoolSize = 6

    private(set) var currentWorld: WorldTheme?

    private init() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    // MARK: - Music

    /// Crossfades to a new world's music + ambience bed. Safe to call every
    /// time the world changes even if the previous track is still the same
    /// (it's a no-op in that case).
    func playMusic(for world: WorldTheme) {
        guard currentWorld != world else { return }
        currentWorld = world
        musicPlayer = makePlayer(named: world.musicTrackName, looping: true)
        musicPlayer?.volume = Float(SaveManager.shared.profile.settings.musicVolume)
        musicPlayer?.play()

        ambiencePlayer = makePlayer(named: world.ambienceTrackName, looping: true)
        ambiencePlayer?.volume = Float(SaveManager.shared.profile.settings.musicVolume) * 0.6
        ambiencePlayer?.play()
    }

    func stopMusic() {
        musicPlayer?.stop()
        ambiencePlayer?.stop()
        musicPlayer = nil
        ambiencePlayer = nil
        currentWorld = nil
    }

    func updateMusicVolume(_ volume: Double) {
        musicPlayer?.volume = Float(volume)
        ambiencePlayer?.volume = Float(volume) * 0.6
    }

    // MARK: - SFX

    /// Plays a short effect using the first free player in the pool,
    /// recycling the pool so long sessions don't leak `AVAudioPlayer`s.
    func playSFX(_ effect: SoundEffect) {
        guard let player = makePlayer(named: effect.fileName, looping: false) else { return }
        player.volume = Float(SaveManager.shared.profile.settings.sfxVolume)
        sfxPlayers.append(player)
        if sfxPlayers.count > sfxPoolSize {
            sfxPlayers.removeFirst()
        }
        player.play()
    }

    // MARK: - Helpers

    private func makePlayer(named resourceName: String, looping: Bool) -> AVAudioPlayer? {
        let candidateExtensions = ["m4a", "caf", "mp3", "wav"]
        guard let url = candidateExtensions.lazy
            .compactMap({ Bundle.main.url(forResource: resourceName, withExtension: $0) })
            .first else { return nil }
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = looping ? -1 : 0
        player?.prepareToPlay()
        return player
    }
}
