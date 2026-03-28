import SwiftUI

@main
struct FrequencyAnalyzerApp: App {
    var body: some Scene {
        WindowGroup {
            TunerView()
                .preferredColorScheme(.dark)
        }
    }
}
