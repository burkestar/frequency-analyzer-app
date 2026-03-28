import AVFoundation
import Foundation
import Observation

@Observable
final class TunerViewModel {
    var tunerData = TunerData()
    var permissionDenied = false

    private let audioEngine = AudioEngine()
    private var smoothedFrequency: Float = 0
    private let smoothingFactor: Float = 0.3

    func start() {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                if granted {
                    self.startAudio()
                } else {
                    self.permissionDenied = true
                }
            }
        }
    }

    func stop() {
        audioEngine.stop()
    }

    private func startAudio() {
        audioEngine.onPitchDetected = { [weak self] pitch in
            DispatchQueue.main.async {
                self?.handlePitch(pitch)
            }
        }

        do {
            try audioEngine.start()
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }

    private func handlePitch(_ pitch: Float?) {
        guard let pitch else {
            tunerData.isActive = false
            return
        }

        // Exponential moving average smoothing
        if smoothedFrequency == 0 {
            smoothedFrequency = pitch
        } else {
            smoothedFrequency = smoothingFactor * pitch + (1 - smoothingFactor) * smoothedFrequency
        }

        let note = NoteMapper.closestNote(to: smoothedFrequency)

        tunerData.frequency = smoothedFrequency
        tunerData.noteName = note.name
        tunerData.octave = note.octave
        tunerData.cents = note.cents
        tunerData.targetFrequency = note.targetFrequency
        tunerData.isActive = true
    }
}
