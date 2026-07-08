import SwiftUI

/// Reusable visual language shared across every screen: soft shadows,
/// rounded "cozy card" backgrounds and a bouncy button press animation. This
/// is what gives the whole UI its consistent, cute cafe-menu feel.
extension View {
    /// The soft, diffused drop shadow used under cards and buttons throughout the app.
    func kawaiiSoftShadow() -> some View {
        self.shadow(color: KawaiiPalette.cocoaBrown.opacity(0.18), radius: 10, x: 0, y: 6)
    }

    /// Wraps content in a rounded, pastel card with a subtle top-to-bottom
    /// gloss and a faint edge highlight — the base building block for most
    /// panels (shop rows, mission rows, settings sections, etc).
    func kawaiiCard(fill: Color = .white, cornerRadius: CGFloat = 24) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill.kawaiiGlossyGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                    )
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

    /// A soft, blurred pastel backdrop of overlapping circles — used behind
    /// full-screen menus to give the plain cream background some depth
    /// without needing a painted illustration.
    func kawaiiDecorativeBackdrop() -> some View {
        self.background(
            ZStack {
                KawaiiPalette.creamWhite
                Circle().fill(KawaiiPalette.mochiPink.opacity(0.22)).frame(width: 260).blur(radius: 40).offset(x: -140, y: -260)
                Circle().fill(KawaiiPalette.skyBlue.opacity(0.22)).frame(width: 220).blur(radius: 40).offset(x: 160, y: -180)
                Circle().fill(KawaiiPalette.honeyYellow.opacity(0.22)).frame(width: 240).blur(radius: 44).offset(x: -120, y: 340)
                Circle().fill(KawaiiPalette.lavender.opacity(0.2)).frame(width: 260).blur(radius: 44).offset(x: 150, y: 420)
            }
            .ignoresSafeArea()
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
