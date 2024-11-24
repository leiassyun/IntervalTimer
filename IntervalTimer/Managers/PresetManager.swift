import SwiftUI

class PresetManager: ObservableObject {
    @Published var presets: [Preset] = [] // Starts empty

    // Function to delete a preset
    func deletePreset(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
    }
}

struct Preset: Identifiable {
    let id = UUID() // Unique identifier
    var name: String
    var workoutDuration: TimeInterval
    var restDuration: TimeInterval
    var repeatCount: Int
}
