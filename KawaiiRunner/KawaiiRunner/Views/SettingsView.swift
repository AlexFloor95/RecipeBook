import SwiftUI

/// Audio/haptics preferences, restore purchases, and a confirmation-gated
/// progress reset.
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingResetConfirmation = false
    @State private var isRestoring = false

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Settings", onClose: { dismiss() })

            Form {
                Section("Audio") {
                    VStack(alignment: .leading) {
                        Label("Music Volume", systemImage: "music.note")
                        Slider(value: $viewModel.settings.musicVolume)
                    }
                    VStack(alignment: .leading) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                        Slider(value: $viewModel.settings.sfxVolume)
                    }
                }

                Section("Feel") {
                    Toggle(isOn: $viewModel.settings.hapticsEnabled) {
                        Label("Haptics", systemImage: "hand.tap.fill")
                    }
                    Toggle(isOn: $viewModel.settings.reduceMotion) {
                        Label("Reduce Motion", systemImage: "figure.walk.motion")
                    }
                }

                Section("Account") {
                    Button {
                        Task {
                            isRestoring = true
                            await viewModel.restorePurchases()
                            isRestoring = false
                        }
                    } label: {
                        Label(isRestoring ? "Restoring..." : "Restore Purchases", systemImage: "arrow.clockwise")
                    }
                    .disabled(isRestoring)
                }

                Section {
                    Button(role: .destructive) {
                        isShowingResetConfirmation = true
                    } label: {
                        Label("Reset Progress", systemImage: "trash.fill")
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .kawaiiDecorativeBackdrop()
        .navigationBarHidden(true)
        .confirmationDialog(
            "This permanently deletes all progress, currency and unlocks. This can't be undone.",
            isPresented: $isShowingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Everything", role: .destructive) { viewModel.resetProgress() }
            Button("Cancel", role: .cancel) {}
        }
    }
}

#Preview {
    SettingsView()
}
