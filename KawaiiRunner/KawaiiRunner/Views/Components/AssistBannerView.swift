import SwiftUI

/// Brief celebratory banner shown when Debbie & Alex help each other out
/// (Team Lift, Buddy Block, Combo Move) — see `GameViewModel.showAssistBanner`.
struct AssistBannerView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.title3, design: .rounded)).bold()
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 22)
            .background(Capsule().fill(KawaiiPalette.mochiPink.opacity(0.9)))
            .kawaiiSoftShadow()
    }
}
