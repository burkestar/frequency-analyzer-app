import SwiftUI

struct TunerView: View {
    @State private var viewModel = TunerViewModel()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.permissionDenied {
                VStack(spacing: 16) {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.red.opacity(0.6))
                    Text("Microphone Access Required")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("Open Settings → FrequencyAnalyzer\nand enable Microphone access.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 32) {
                    Spacer()

                    NoteDisplay(
                        noteName: viewModel.tunerData.noteName,
                        octave: viewModel.tunerData.octave,
                        isActive: viewModel.tunerData.isActive
                    )

                    FrequencyDisplay(
                        frequency: viewModel.tunerData.frequency,
                        targetFrequency: viewModel.tunerData.targetFrequency,
                        isActive: viewModel.tunerData.isActive
                    )

                    Spacer()

                    TunerGauge(
                        cents: viewModel.tunerData.cents,
                        isActive: viewModel.tunerData.isActive
                    )

                    Spacer()
                }
                .padding()
            }
        }
        .onAppear { viewModel.start() }
        .onDisappear { viewModel.stop() }
    }
}
