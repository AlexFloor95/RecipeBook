import SwiftUI

/// Reusable visual language shared across every screen: soft shadows,
/// rounded "cozy card" backgrounds and a bouncy button press animation. This
/// is what gives the whole UI its consistent, cute cafe-menu feel.
extension View {
    /// The soft, diffused drop shadow used under cards and buttons throughout the app.
    func kawaiiSoftShadow() -> some View {
        self.shadow(color: KawaiiPalette.cocoaBrown.opacity(0.18), radius: 10, x: 0, y: 6)
    }

    /// Wraps content in a rounded, pastel card — the base building block for
    /// most panels (shop rows, mission rows, settings sections, etc).
    func kawaiiCard(fill: Color = .white, cornerRadius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .kawaiiSoftShadow()
    }

    /// Rounded pill border, handy for badges and chips.
    func kawaiiOutline(color: Color, lineWidth: CGFloat = 2, cornerRadius: CGFloat = 20) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color, lineWidth: lineWidth)
        )
    }
}

/// A springy scale-down-on-press effect used by `KawaiiButton` and any other
/// tappable element that should feel soft and squishy rather than flat.
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == BouncyButtonStyle {
    static var bouncy: BouncyButtonStyle { BouncyButtonStyle() }
}
