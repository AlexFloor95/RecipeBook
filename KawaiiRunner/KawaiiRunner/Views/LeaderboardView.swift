import SwiftUI
import UIKit

/// On-device top-20 leaderboard, with an optional hand-off to Apple's
/// native Game Center leaderboard UI when the player is signed in.
struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Leaderboard", onClose: { dismiss() })

            if viewModel.isGameCenterAvailable {
                Button {
                    if let rootViewController = UIApplication.shared.connectedScenes
                        .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                        .first?.rootViewController {
                        viewModel.presentGameCenter(from: rootViewController)
                    }
                } label: {
                    Label("View Global Leaderboard", systemImage: "globe")
                        .font(.system(.caption, design: .rounded)).bold()
                }
                .padding(.bottom, 4)
            }

            if viewModel.entries.isEmpty {
                Spacer()
                Text("No runs yet — go set a score! 🏃")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                            row(rank: index + 1, entry: entry)
                        }
                    }
                    .padding()
                }
            }
        }
        .background(KawaiiPalette.creamWhite.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func row(rank: Int, entry: LeaderboardEntry) -> some View {
        HStack {
            Text("#\(rank)")
                .font(.system(.headline, design: .rounded)).bold()
                .foregroundStyle(rank <= 3 ? KawaiiPalette.honeyYellow : KawaiiPalette.textDark)
                .frame(width: 36)
            Text(entry.character == .debbie ? "🌸" : "🐾")
            VStack(alignment: .leading) {
                Text("\(entry.score) pts").font(.system(.subheadline, design: .rounded)).bold()
                Text("\(entry.distanceMeters)m • \(entry.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .kawaiiCard()
    }
}

#Preview {
    LeaderboardView()
}
