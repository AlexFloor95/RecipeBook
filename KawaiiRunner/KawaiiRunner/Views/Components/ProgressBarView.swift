import SwiftUI

/// A rounded, pastel progress bar used for XP, mission progress, the Combo
/// Meter, and the Lucky Wheel streak calendar.
struct ProgressBarView: View {
    /// 0...1
    let fraction: Double
    var fillColor: Color = KawaiiPalette.mochiPink
    var trackColor: Color = Color.white.opacity(0.5)
    var height: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(trackColor)
                Capsule()
                    .fill(fillColor.gradient)
                    .frame(width: max(height, geo.size.width * min(1, max(0, fraction))))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: fraction)
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 12) {
        ProgressBarView(fraction: 0.35)
        ProgressBarView(fraction: 0.8, fillColor: KawaiiPalette.skyBlue)
    }
    .padding()
    .background(KawaiiPalette.creamWhite)
}
