import SwiftUI

/// Full-screen dimmed overlay shown while a run is paused: resume, restart,
/// or quit back to the Home screen.
struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Paused")
                    .font(.system(.largeTitle, design: .rounded)).bold()
                    .foregroundStyle(.white)

                VStack(spacing: 14) {
                    KawaiiButton(title: "Resume", systemImage: "play.fill", action: onResume)
                    KawaiiButton(title: "Restart", systemImage: "arrow.counterclockwise", emphasis: .secondary, action: onRestart)
                    KawaiiButton(title: "Quit to Home", systemImage: "house.fill", emphasis: .destructive, action: onQuit)
                }
                .frame(maxWidth: 280)
            }
            .padding(28)
            .kawaiiCard(fill: .white.opacity(0.95))
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    PauseMenuView(onResume: {}, onRestart: {}, onQuit: {})
}
