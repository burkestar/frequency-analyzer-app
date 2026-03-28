import SwiftUI

struct TunerGauge: View {
    let cents: Float
    let isActive: Bool

    private var normalizedOffset: CGFloat {
        CGFloat(cents / 50.0)
    }

    private var indicatorColor: Color {
        let absCents = abs(cents)
        if absCents < 5 {
            return .green
        } else if absCents < 15 {
            return .yellow
        } else {
            return .orange
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Cents readout
            Text(isActive ? String(format: "%+.0f ¢", cents) : "-- ¢")
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .foregroundStyle(isActive ? indicatorColor : .gray.opacity(0.4))

            // Gauge
            GeometryReader { geometry in
                let width = geometry.size.width
                let centerX = width / 2
                let indicatorX = centerX + (normalizedOffset * centerX * 0.9)

                ZStack {
                    // Track background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)

                    // Tick marks
                    ForEach([-50, -25, 0, 25, 50], id: \.self) { tick in
                        let x = centerX + CGFloat(Float(tick) / 50.0) * centerX * 0.9
                        Rectangle()
                            .fill(tick == 0 ? Color.green : Color.white.opacity(0.3))
                            .frame(width: tick == 0 ? 2 : 1, height: tick == 0 ? 28 : 16)
                            .position(x: x, y: geometry.size.height / 2)
                    }

                    // Indicator needle
                    if isActive {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(indicatorColor)
                            .frame(width: 4, height: 36)
                            .shadow(color: indicatorColor.opacity(0.6), radius: 6)
                            .position(x: indicatorX, y: geometry.size.height / 2)
                            .animation(.easeOut(duration: 0.08), value: cents)
                    }
                }
            }
            .frame(height: 40)

            // Labels
            HStack {
                Text("FLAT")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
                Spacer()
                Text("IN TUNE")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(isActive && abs(cents) < 5 ? .green : .white.opacity(0.3))
                Spacer()
                Text("SHARP")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(.horizontal, 24)
    }
}
