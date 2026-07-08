import SwiftUI

/// Lets the player choose which of Debbie/Alex leads the run (the other
/// automatically becomes the supportive buddy — see `BuddyAssist`).
struct CharacterSelectView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SectionHeader(title: "Choose Your Lead", onClose: { dismiss() })

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(CharacterType.allCases) { character in
                        card(for: character)
                    }
                }
                .padding()
            }
        }
        .background(KawaiiPalette.creamWhite.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private func card(for character: CharacterType) -> some View {
        let isSelected = viewModel.profile.selectedLeadCharacter == character
        return Button {
            viewModel.selectLead(character)
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: character.themeColorHex).gradient)
                    .frame(width: 72, height: 72)
                    .overlay(Text(character == .debbie ? "🌸" : "🐾").font(.system(size: 30)))

                VStack(alignment: .leading, spacing: 4) {
                    Text(character.displayName)
                        .font(.system(.title3, design: .rounded)).bold()
                        .foregroundStyle(KawaiiPalette.textDark)
                    Text(character.tagline)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(KawaiiPalette.textDark.opacity(0.6))
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(KawaiiPalette.mochiPink)
                }
            }
            .padding()
            .kawaiiCard()
            .kawaiiOutline(color: isSelected ? KawaiiPalette.mochiPink : .clear, lineWidth: 3)
        }
        .buttonStyle(.bouncy)
    }
}

#Preview {
    CharacterSelectView(viewModel: HomeViewModel())
}
