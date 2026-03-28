import SwiftUI

struct NoteDisplay: View {
    let noteName: String
    let octave: Int
    let isActive: Bool

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(noteName)
                .font(.system(size: 96, weight: .bold, design: .rounded))
            Text("\(octave)")
                .font(.system(size: 42, weight: .medium, design: .rounded))
        }
        .foregroundStyle(isActive ? .white : .gray.opacity(0.3))
        .animation(.easeOut(duration: 0.15), value: noteName)
        .animation(.easeOut(duration: 0.15), value: isActive)
    }
}
