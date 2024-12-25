import SwiftUI


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


struct Preset: Identifiable {
    let id = UUID()
    var name: String
    var workouts: [Workout]
    var totalDuration: Int
    
    // Formatted total duration in MM:SS format
    var fTotalDuration: String {
        let minutes = totalDuration / 60
        let seconds = totalDuration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    var fMin: String {
        return String(totalDuration / 60)
    }
    var fSec: String {
        return String(format: "%02d", totalDuration % 60)
    }
}

class PresetManager: ObservableObject {
    @Published var presets: [Preset] = []
    
    func addPreset(name: String, workouts: [Workout]) {
        let totalDuration = workouts.reduce(0) { $0 + $1.duration }
        let newPreset = Preset(name: name, workouts: workouts, totalDuration: totalDuration)
        presets.append(newPreset)
    }
    func updateWorkoutDuration(currentWorkout: Workout, minutes: Int, seconds: Int) -> Workout {
        let totalSeconds = min((minutes * 60) + seconds, 99 * 60 + 59)
        return Workout(name: currentWorkout.name, duration: totalSeconds)
    }
    
    func createWorkout(name: String, duration: Int) -> Workout {
        return Workout(name: name, duration: duration)
    }
    
    func deletePreset(at offsets: IndexSet) {
        presets.remove(atOffsets: offsets)
    }
    
    func addWorkout(to presetID: UUID, workout: Workout) {
        if let index = presets.firstIndex(where: { $0.id == presetID }) {
            presets[index].workouts.append(workout)
            presets[index].totalDuration = presets[index].workouts.reduce(0) { $0 + $1.duration }
        }
    }
    func duplicatePreset(presetID: UUID) {
        guard let presetToDuplicate = presets.first(where: { $0.id == presetID }) else { return }
        
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
        
        addPreset(name: newName, workouts: presetToDuplicate.workouts)
    }
    
    func deletePreset(by presetID: UUID) {
        if let index = presets.firstIndex(where: { $0.id == presetID }) {
            deletePreset(at: IndexSet(integer: index))
        }
    }
    var fTotalDuration: String {
        let totalSeconds = presets.reduce(0) { $0 + $1.totalDuration }
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
