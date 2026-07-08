import SwiftUI
import Combine

/// Drives the Settings screen: audio/haptics preferences (persisted via
/// `SaveManager`), restore purchases, and the (confirmation-gated) progress
/// reset action.
@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: GameSettings {
        didSet { persist() }
    }

    private var cancellable: AnyCancellable?

    init() {
        settings = SaveManager.shared.profile.settings
        cancellable = SaveManager.shared.$profile
            .map(\.settings)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self, self.settings != $0 else { return }
                self.settings = $0
            }
    }

    private func persist() {
        var profile = SaveManager.shared.profile
        guard profile.settings != settings else { return }
        profile.settings = settings
        SaveManager.shared.profile = profile
        SaveManager.shared.scheduleSave()
        AudioManager.shared.updateMusicVolume(settings.musicVolume)
    }

    func restorePurchases() async {
        await IAPManager.shared.restorePurchases()
    }

    func resetProgress() {
        SaveManager.shared.resetProgress()
        settings = SaveManager.shared.profile.settings
    }
}
