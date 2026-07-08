import SwiftUI

/// The Day-7 bonus wheel: a segmented pie of `LuckyWheelPrize`s that spins
/// to a dramatic stop on the result already chosen by
/// `LuckyWheelPrize.spin(using:)` in the view model.
struct LuckyWheelView: View {
    @ObservedObject var viewModel: DailyRewardsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var rotation: Double = 0
    @State private var hasSpun = false

    private let prizes = LuckyWheelPrize.wheel

    var body: some View {
        VStack(spacing: 24) {
            Text("Lucky Wheel")
                .font(.system(.title, design: .rounded)).bold()
                .foregroundStyle(KawaiiPalette.textDark)

            ZStack {
                wheel
                    .rotationEffect(.degrees(rotation))
                    .animation(.easeOut(duration: 2.2), value: rotation)
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.title)
                    .foregroundStyle(KawaiiPalette.textDark)
                    .offset(y: -140)
            }
            .frame(width: 260, height: 260)

            if let result = viewModel.lastSpinResult {
                Text("You won \(result.label)!")
                    .font(.system(.headline, design: .rounded)).bold()
                    .foregroundStyle(KawaiiPalette.mochiPink)
            }

            KawaiiButton(title: hasSpun ? "Nice!" : "Spin!", systemImage: hasSpun ? "checkmark" : "arrow.triangle.2.circlepath") {
                if hasSpun {
                    dismiss()
                } else {
                    spin()
                }
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    private var wheel: some View {
        ZStack {
            ForEach(Array(prizes.enumerated()), id: \.element.id) { index, prize in
                let sliceAngle = 360.0 / Double(prizes.count)
                PieSlice(startAngle: .degrees(sliceAngle * Double(index)), endAngle: .degrees(sliceAngle * Double(index + 1)))
                    .fill(Color(hex: prize.colorHex))
            }
        }
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 4))
        .kawaiiSoftShadow()
    }

    private func spin() {
        guard !hasSpun else { return }
        let prize = viewModel.spinWheel()
        let index = prizes.firstIndex(where: { $0.id == prize.id }) ?? 0
        let sliceAngle = 360.0 / Double(prizes.count)
        let targetAngle = 360.0 * 5 + (360.0 - (sliceAngle * Double(index) + sliceAngle / 2))
        rotation = targetAngle
        hasSpun = true
        AudioManager.shared.playSFX(.wheelSpin)
        HapticsManager.shared.impact(.medium)
    }
}

/// A single pie-chart wedge, used to draw each wheel segment.
private struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: rect.width / 2, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    LuckyWheelView(viewModel: DailyRewardsViewModel())
}
