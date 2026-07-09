import SwiftUI

/// Small pill showing an icon + amount, used for coins/tokens/XP wherever
/// currency needs to be displayed (Home header, Shop header, Game Over).
struct CurrencyBadge: View {
    let systemImage: String
    let value: Int
    var tint: Color = KawaiiPalette.honeyYellow
    /// Spoken name for VoiceOver (e.g. "Coins", "Coco Tokens"); falls back
    /// to a generic "Amount" if not provided.
    var accessibilityName: String = "Amount"

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .foregroundStyle(tint)
            Text("\(value)")
                .font(.system(.subheadline, design: .rounded)).bold()
                .foregroundStyle(KawaiiPalette.textDark)
                .contentTransition(.numericText())
                .animation(.snappy, value: value)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.92).kawaiiGlossyGradient)
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.6), lineWidth: 1))
        )
        .kawaiiSoftShadow()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(accessibilityName): \(value)")
    }
}

#Preview {
    HStack {
        CurrencyBadge(systemImage: "dollarsign.circle.fill", value: 1240, accessibilityName: "Coins")
        CurrencyBadge(systemImage: "sparkles", value: 12, tint: KawaiiPalette.lavender, accessibilityName: "Coco Tokens")
    }
    .padding()
    .background(KawaiiPalette.creamWhite)
}
