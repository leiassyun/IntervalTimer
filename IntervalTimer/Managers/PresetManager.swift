import SwiftUI

// Workout structure
struct Workout: Identifiable {
    let id = UUID() // Unique identifier
    var name: String // Name of the workout
    var duration: Int // Duration in seconds
    var fDuration: String { // Computed property for formatted duration
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// Preset structure
struct Preset: Identifiable {
    let id = UUID() // Unique identifier for each preset
    var name: String // Name of the preset
    var workouts: [Workout] // List of workouts in the preset
    var totalDuration: Int // Total duration of all workouts in seconds

    // Formatted total duration in MM:SS format
    var fTotalDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// PresetManager class
class PresetManager: ObservableObject {
    @Published var presets: [Preset] = [] // Starts empty

    // Add a new preset
    func addPreset(name: String, workouts: [Workout]) {
           let totalDuration = workouts.reduce(0) { $0 + $1.duration }
           let newPreset = Preset(name: name, workouts: workouts, totalDuration: totalDuration)
           presets.append(newPreset)
       }

    // Function to delete a preset
    func deletePreset(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
    }

    // Function to add a workout to a specific preset
    func addWorkout(to presetID: UUID, workout: Workout) {
            if let index = presets.firstIndex(where: { $0.id == presetID }) {
                presets[index].workouts.append(workout)
                // Recalculate total duration
                presets[index].totalDuration = presets[index].workouts.reduce(0) { $0 + $1.duration }
            }
        }
}
