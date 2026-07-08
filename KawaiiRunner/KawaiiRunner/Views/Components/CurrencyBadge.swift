import SwiftUI

/// Small pill showing an icon + amount, used for coins/tokens/XP wherever
/// currency needs to be displayed (Home header, Shop header, Game Over).
struct CurrencyBadge: View {
    let systemImage: String
    let value: Int
    var tint: Color = KawaiiPalette.honeyYellow

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
    }
}

#Preview {
    HStack {
        CurrencyBadge(systemImage: "dollarsign.circle.fill", value: 1240)
        CurrencyBadge(systemImage: "sparkles", value: 12, tint: KawaiiPalette.lavender)
    }
    .padding()
    .background(KawaiiPalette.creamWhite)
}
