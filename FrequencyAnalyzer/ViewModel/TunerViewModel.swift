import AVFoundation
import Foundation
import Observation

@Observable
final class TunerViewModel {
    var tunerData = TunerData()
    var permissionDenied = false

    private let audioEngine = AudioEngine()
    private var smoothedFrequency: Float = 0
    private let smoothingFactor: Float = 0.15
    // Note stabilization: require consecutive readings near the same note before switching
    private var currentNoteMidi: Int = -1
    private var candidateNoteMidi: Int = -1
    private var candidateCount: Int = 0
    private let switchThreshold: Int = 4

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

        // Heavier EMA smoothing to tame initial transients
        if smoothedFrequency == 0 {
            smoothedFrequency = pitch
        } else {
            smoothedFrequency = smoothingFactor * pitch + (1 - smoothingFactor) * smoothedFrequency
        }

        let note = NoteMapper.closestNote(to: smoothedFrequency)
        let midi = note.midiNote

        // Note-lock hysteresis: only switch displayed note after several
        // consecutive readings agree on a new note
        if midi == currentNoteMidi {
            // Already showing this note — just update frequency/cents
            candidateNoteMidi = -1
            candidateCount = 0
        } else if midi == candidateNoteMidi {
            candidateCount += 1
            if candidateCount >= switchThreshold {
                currentNoteMidi = midi
                candidateNoteMidi = -1
                candidateCount = 0
            } else {
                // Still waiting — keep displaying the locked note, but update
                // frequency so the Hz readout stays responsive
                tunerData.frequency = smoothedFrequency
                tunerData.isActive = true
                return
            }
        } else {
            // New candidate — start counting
            candidateNoteMidi = midi
            candidateCount = 1
            if currentNoteMidi == -1 {
                // First ever reading — show it immediately
                currentNoteMidi = midi
            } else {
                tunerData.frequency = smoothedFrequency
                tunerData.isActive = true
                return
            }
        }

        tunerData.frequency = smoothedFrequency
        tunerData.noteName = note.name
        tunerData.octave = note.octave
        tunerData.cents = note.cents
        tunerData.targetFrequency = note.targetFrequency
        tunerData.isActive = true
    }
}
