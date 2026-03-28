import Foundation

struct NoteInfo {
    let name: String
    let octave: Int
    let cents: Float
    let targetFrequency: Float
}

enum NoteMapper {
    private static let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    static func closestNote(to frequency: Float) -> NoteInfo {
        let semitonesFromA4 = 12.0 * log2(Double(frequency) / 440.0)
        let roundedSemitones = round(semitonesFromA4)
        let cents = Float((semitonesFromA4 - roundedSemitones) * 100.0)

        let midiNote = Int(roundedSemitones) + 69
        let noteIndex = ((midiNote % 12) + 12) % 12
        let octave = (midiNote / 12) - 1

        let targetFrequency = Float(440.0 * pow(2.0, roundedSemitones / 12.0))

        return NoteInfo(
            name: noteNames[noteIndex],
            octave: octave,
            cents: cents,
            targetFrequency: targetFrequency
        )
    }
}
