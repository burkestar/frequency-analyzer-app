import Accelerate
import AVFoundation
import Foundation

final class AudioEngine {
    private let engine = AVAudioEngine()
    private var pitchDetector: PitchDetector?
    var onPitchDetected: ((Float?) -> Void)?

    var sampleRate: Float {
        Float(engine.inputNode.outputFormat(forBus: 0).sampleRate)
    }

    func start() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.record, mode: .measurement, options: [])
        try session.setActive(true)

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        let rate = Float(format.sampleRate)

        pitchDetector = PitchDetector(sampleRate: rate)

        let bufferSize: AVAudioFrameCount = 4096
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: format) { [weak self] buffer, _ in
            guard let self,
                  let channelData = buffer.floatChannelData?[0] else { return }

            let frames = Int(buffer.frameLength)

            // RMS silence gate
            var rms: Float = 0
            vDSP_rmsqv(channelData, 1, &rms, vDSP_Length(frames))

            if rms < 0.01 {
                self.onPitchDetected?(nil)
                return
            }

            let pitch = self.pitchDetector?.detectPitch(
                buffer: channelData,
                frameCount: frames
            )
            self.onPitchDetected?(pitch)
        }

        engine.prepare()
        try engine.start()
    }

    func stop() {
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
    }
}
