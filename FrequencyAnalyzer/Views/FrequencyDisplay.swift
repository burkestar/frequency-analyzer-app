import SwiftUI

struct FrequencyDisplay: View {
    let frequency: Float
    let targetFrequency: Float
    let isActive: Bool

    var body: some View {
        VStack(spacing: 4) {
            Text(isActive ? String(format: "%.1f Hz", frequency) : "-- Hz")
                .font(.system(size: 32, weight: .light, design: .monospaced))
                .foregroundStyle(isActive ? .white : .gray.opacity(0.3))

            if isActive && targetFrequency > 0 {
                Text(String(format: "Target: %.1f Hz", targetFrequency))
                    .font(.system(size: 14, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
}
