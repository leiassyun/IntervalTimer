import SwiftUI
import Foundation


struct Workout: Identifiable, Codable {
    var id = UUID() 
    var name: String // Name of the workout
    var duration: Int // Duration in seconds
    var fDuration: String { // Computed property for formatted duration
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    init(id: UUID = UUID(), name: String, duration: TimeInterval) {
            self.id = id
            self.name = name
            self.duration = Int(duration)
        }
}


struct Preset: Identifiable, Codable {
    var id = UUID()
    var name: String
    var workouts: [Workout]
    var totalDuration: Int
    init(id: UUID = UUID(), name: String, workouts: [Workout], totalDuration: TimeInterval) {
           self.id = id
           self.name = name
           self.workouts = workouts
           self.totalDuration = Int(totalDuration)
       }
    
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
    @Published var quickStartWorkouts: [Workout] = []
    @Published var presets: [Preset] = [] {
        didSet {
            savePresets()
        }
    }
    private let presetsKey = "savedPresets"
    init() {
        loadPresets()
    }
    func savePresets() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(presets)
            UserDefaults.standard.set(data, forKey: presetsKey)
        } catch {
            print("Failed to save presets: \(error)")
        }
    }
    
    
    func createQuickStartPreset(sets: Int, workoutDuration: TimeInterval, restDuration: TimeInterval) -> Preset {
        var workouts: [Workout] = []

           if sets == 1 {
               workouts.append(createWorkout(name: "Workout", duration: Double(workoutDuration)))
           } else {
               workouts = (1...sets).flatMap { _ in
                   [
                       createWorkout(name: "Workout", duration: Double(workoutDuration)),
                       createWorkout(name: "Rest", duration: Double(restDuration))
                   ]
               }
           }
        let totalDuration = workouts.reduce(0) { $0 + $1.duration }
        
        let preset = Preset(name: "Quick Start", workouts: workouts, totalDuration: Double(totalDuration))
        return preset
    }
    
    func loadPresets() {
        guard let data = UserDefaults.standard.data(forKey: presetsKey) else { return }
        do {
            let decoder = JSONDecoder()
            presets = try decoder.decode([Preset].self, from: data)
        } catch {
            print("Failed to load presets: \(error)")
        }
    }
    func addPresetP(newPreset: Preset) {
        presets.append(newPreset)
        savePresets()
        objectWillChange.send()
        print("PresetManager: Preset added to list.")

    }
    func addPreset(name: String, workouts: [Workout]) {
        let totalDuration = Double(workouts.reduce(0) { $0 + $1.duration })
        let newPreset = Preset(name: name, workouts: workouts, totalDuration: totalDuration)
        presets.append(newPreset)
    }
    func updateWorkoutDuration(currentWorkout: Workout, minutes: Int, seconds: Int) -> Workout {
        let totalSeconds = Double(min((minutes * 60) + seconds, 99 * 60 + 59))
        return Workout(name: currentWorkout.name, duration: totalSeconds)
    }
    func updatePreset(preset: Preset, workouts: [Workout], name: String) {
        if let index = presets.firstIndex(where: { $0.id == preset.id }) {
            presets[index].workouts = workouts
            presets[index].name = name
            presets[index].totalDuration = workouts.reduce(0) { $0 + $1.duration }
        }
    }
    
    func createWorkout(name: String, duration: Double = 60) -> Workout {
        return Workout(name: name, duration: duration)
    }
    
    func deleteWorkout(fromPresetID presetID: UUID, workoutID: UUID) {
        guard let presetIndex = presets.firstIndex(where: { $0.id == presetID }) else { return }
        guard let workoutIndex = presets[presetIndex].workouts.firstIndex(where: { $0.id == workoutID }) else { return }
        presets[presetIndex].workouts.remove(at: workoutIndex)
    }
    func deletePreset(presetID: UUID) {
           guard let index = presets.firstIndex(where: { $0.id == presetID }) else { return }
           presets.remove(at: index)
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
    
    
    var fTotalDuration: String {
        let totalSeconds = presets.reduce(0) { $0 + $1.totalDuration }
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Preset {
    func toJSON() -> String? {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
extension TimeInterval {
    var minutes: Int {
        get { Int(self) / 60 }
        set {
            // Recalculate the total seconds when minutes are updated
            self = Double(newValue * 60 + seconds)
        }
    }

    var seconds: Int {
        get { Int(self) % 60 }
        set {
            // Ensure seconds roll over to minutes if they exceed 59
            let total = (minutes * 60) + newValue
            self = Double(total)
        }
    }

    var formatted: String {
        // Return the time in "MM:SS" format
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
