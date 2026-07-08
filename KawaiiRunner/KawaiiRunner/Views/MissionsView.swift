import SwiftUI

/// Daily Missions / Weekly Challenges screen with a segmented tab switcher.
struct MissionsView: View {
    @StateObject private var viewModel = MissionsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Missions", onClose: { dismiss() })

            Picker("Tab", selection: $viewModel.selectedTab) {
                Text("Daily").tag(MissionsViewModel.Tab.daily)
                Text("Weekly").tag(MissionsViewModel.Tab.weekly)
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.visibleMissions) { mission in
                        MissionRow(mission: mission)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(KawaiiPalette.creamWhite.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

private struct MissionRow: View {
    let mission: Mission

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(mission.title)
                    .font(.system(.subheadline, design: .rounded)).bold()
                    .foregroundStyle(KawaiiPalette.textDark)
                ProgressBarView(fraction: mission.progressFraction, fillColor: mission.isComplete ? KawaiiPalette.matchaGreen : KawaiiPalette.mochiPink, height: 10)
                Text("\(min(mission.progressValue, mission.targetValue))/\(mission.targetValue)")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if mission.isComplete {
                Image(systemName: "checkmark.seal.fill")
                    .font(.title2)
                    .foregroundStyle(KawaiiPalette.matchaGreen)
            } else {
                VStack(spacing: 2) {
                    Text("+\(mission.rewardCoins)")
                        .font(.system(.caption, design: .rounded)).bold()
                    Image(systemName: "dollarsign.circle.fill").foregroundStyle(KawaiiPalette.honeyYellow)
                }
            }
        }
        .padding()
        .kawaiiCard()
    }
}

#Preview {
    MissionsView()
}
