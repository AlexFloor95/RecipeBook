import SwiftUI

/// Consistent section title used at the top of every full-screen menu
/// (Shop, Missions, Achievements, ...), with an optional close/back button.
struct SectionHeader: View {
    let title: String
    var onClose: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.system(.title2, design: .rounded)).bold()
                .foregroundStyle(KawaiiPalette.textDark)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            if let onClose {
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(KawaiiPalette.textDark.opacity(0.4))
                }
                .accessibilityLabel("Close")
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }
}
