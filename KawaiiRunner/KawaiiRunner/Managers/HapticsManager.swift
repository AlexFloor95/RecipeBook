import UIKit

/// Thin wrapper around `UIFeedbackGenerator` so gameplay code can say
/// `Haptics.shared.tap(.light)` without worrying about generator lifecycle
/// or whether the player has haptics disabled in Settings.
@MainActor
final class HapticsManager {
    static let shared = HapticsManager()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()

    private var isEnabled: Bool { SaveManager.shared.profile.settings.hapticsEnabled }

    private init() {}

    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        switch style {
        case .light: lightImpact.impactOccurred()
        case .heavy: heavyImpact.impactOccurred()
        default: mediumImpact.impactOccurred()
        }
    }

    func success() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }

    func warning() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    /// Called ahead of a burst of haptics (e.g. right before a run starts)
    /// so the Taptic Engine is warmed up and the first hit isn't delayed.
    func prepareAll() {
        guard isEnabled else { return }
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notification.prepare()
    }
}
