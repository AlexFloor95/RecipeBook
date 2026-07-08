import SwiftUI

/// The single reusable button style used across every menu screen: a big,
/// rounded, pastel-filled pill with a soft shadow and a bouncy press
/// animation. Keeping one component here (rather than hand-styling buttons
/// per screen) is what makes the whole app feel cohesive.
struct KawaiiButton: View {
    enum Emphasis { case primary, secondary, destructive }

    let title: String
    var systemImage: String?
    var emphasis: Emphasis = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.bold)
            }
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(foregroundColor)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity)
            .background(
                Capsule().fill(backgroundColor)
            )
            .kawaiiSoftShadow()
        }
        .buttonStyle(.bouncy)
    }

    private var backgroundColor: Color {
        switch emphasis {
        case .primary: return KawaiiPalette.mochiPink
        case .secondary: return .white
        case .destructive: return Color(hex: "#FF6F6F")
        }
    }

    private var foregroundColor: Color {
        switch emphasis {
        case .primary, .destructive: return .white
        case .secondary: return KawaiiPalette.textDark
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        KawaiiButton(title: "Play", systemImage: "play.fill", action: {})
        KawaiiButton(title: "Shop", emphasis: .secondary, action: {})
        KawaiiButton(title: "Reset Progress", emphasis: .destructive, action: {})
    }
    .padding()
    .background(KawaiiPalette.creamWhite)
}
