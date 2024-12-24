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
// preset.workouts
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
    
    // PresetManager class
    
        // Function to duplicate a preset
        func duplicatePreset(presetID: UUID) {
            // Find the preset to duplicate
            guard let presetToDuplicate = presets.first(where: { $0.id == presetID }) else { return }

            // Generate a unique name by checking for existing presets
            var newName = presetToDuplicate.name
            var counter = 1

            while presets.contains(where: { $0.name == newName }) {
                if let digits = Int(String(newName.reversed().prefix { $0.isNumber }.reversed())) {
                    let baseName = newName.dropLast(String(digits).count)
                    counter = digits + 1
                    newName = "\(baseName)\(counter)"
                } else {
                    newName = "\(presetToDuplicate.name)\(counter)"
                    counter += 1
                }
            }

            // Use the addPreset function to create the duplicated preset
            addPreset(name: newName, workouts: presetToDuplicate.workouts)
        }

        // Function to delete a preset by UUID
        func deletePreset(by presetID: UUID) {
            // Find the index of the preset to delete
            if let index = presets.firstIndex(where: { $0.id == presetID }) {
                // Use the existing deletePreset(at:) method
                deletePreset(at: IndexSet(integer: index))
            }
        }
    
}
