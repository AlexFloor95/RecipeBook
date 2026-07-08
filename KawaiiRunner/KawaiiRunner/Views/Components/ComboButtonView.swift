import SwiftUI

/// The Combo Meter + activation button, docked bottom-center for easy
/// one-handed thumb reach. Fills as Hearts/Stars are collected; glows and
/// becomes tappable once full, triggering the Team Combo Move.
struct ComboButtonView: View {
    let hud: GameHUDState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9).kawaiiGlossyGradient)
                    .frame(width: 76, height: 76)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
                    .kawaiiSoftShadow()
                Circle()
                    .trim(from: 0, to: hud.comboMeterFraction)
                    .stroke(
                        hud.isComboActive ? KawaiiPalette.honeyYellow : KawaiiPalette.mochiPink,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 76, height: 76)
                    .animation(.spring, value: hud.comboMeterFraction)
                Text("💞")
                    .font(.system(size: 30))
                    .scaleEffect(hud.isComboReady ? 1.15 : 1.0)
                    .animation(hud.isComboReady ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: hud.isComboReady)
            }
        }
        .disabled(!hud.isComboReady)
        .opacity(hud.isComboActive ? 0.5 : 1.0)
    }
}
