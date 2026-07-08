import SwiftUI

/// The always-visible in-run overlay: score, coins, distance, current world
/// name, active power-up icons, and the pause button. Deliberately minimal
/// and top-anchored so it never gets in the way of one-handed play.
struct GameHUDView: View {
    let hud: GameHUDState
    let onPause: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(hud.score)")
                    .font(.system(.title, design: .rounded)).bold()
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                Text("\(hud.distanceMeters)m • \(hud.currentWorld.displayName)")
                    .font(.system(.caption, design: .rounded)).bold()
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(radius: 1)
                HStack(spacing: 8) {
                    if hud.isShielded {
                        Label("Shield", systemImage: "shield.fill").labelStyle(.iconOnly)
                            .foregroundStyle(KawaiiPalette.skyBlue)
                    }
                    if hud.isMagnetActive {
                        Label("Magnet", systemImage: "circle.hexagongrid.fill").labelStyle(.iconOnly)
                            .foregroundStyle(KawaiiPalette.honeyYellow)
                    }
                }
                .font(.title3)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 10) {
                Button(action: onPause) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                }
                CurrencyBadge(systemImage: "dollarsign.circle.fill", value: hud.coins)
            }
        }
        .padding()
        .padding(.top, 8)
    }
}
