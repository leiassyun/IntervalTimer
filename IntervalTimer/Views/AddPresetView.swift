import SwiftUI

struct AddPresetView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @ObservedObject var presetManager: PresetManager
    @Binding var selectedTab: Int
    @State private var selectedPreset: Preset?
    @State private var isOverlayVisible = false
    
    @Environment(\.dismiss) var dismiss
    @State private var presetName = ""
    @State private var workouts: [Workout] = []
    
    // States for workout modal
    @State private var isShowingWorkoutModal = false
    @State private var workoutName = ""
    @State private var workoutMinutes = 1
    @State private var workoutSeconds = 0
    @FocusState private var isWorkoutNameFocused: Bool
    
    
    init(selectedPreset: Preset?, presetManager: PresetManager, selectedTab: Binding<Int>) {
        _presetName = State(initialValue: selectedPreset?.name ?? "")
        _workouts = State(initialValue: selectedPreset?.workouts ?? [])
        self.selectedPreset = selectedPreset // Use this variable
        _presetManager = ObservedObject(wrappedValue: presetManager)
        _selectedTab = selectedTab
    }
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack {
                    Text("New Preset")
                        .font(.title)
                        .bold()
                        .foregroundColor(appearanceManager.fontColor)
                    Spacer()
                    Text("Total: \(calculateTotalDuration())")
                        .font(.headline)
                        .bold()
                        .foregroundColor(appearanceManager.fontColor)
                }
                .padding(.horizontal)
                .padding(.top)
                .background(appearanceManager.backgroundColor)
                
                Spacer().frame(height: 20)
                ScrollView {
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(workouts.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "clock")
                                    .foregroundColor(appearanceManager.fontColor)
                                
                                TextField("Session name", text: $workouts[index].name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(appearanceManager.fontColor)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.vertical, 5)
                                    .background(Color.clear)
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    TextField(
                                        "",
                                        text: Binding(
                                            get: {
                                                String(workouts[index].duration / 60)
                                            },
                                            set: { newValue in
                                                if let intValue = Int(newValue), intValue >= 0 {
                                                    let updatedWorkout = presetManager.updateWorkoutDuration(
                                                        currentWorkout: workouts[index],
                                                        minutes: intValue,
                                                        seconds: workouts[index].duration % 60
                                                    )
                                                    workouts[index] = updatedWorkout
                                                }
                                            }
                                        )
                                    )
                                    .keyboardType(.numberPad)
                                    .foregroundColor(appearanceManager.fontColor)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .frame(minWidth: 30, maxWidth: 50, alignment: .trailing)
                                    .multilineTextAlignment(.trailing)
                                    
                                    Text(":")
                                        .foregroundColor(appearanceManager.fontColor)
                                        .font(.system(size: 24, weight: .bold))
                                    
                                    
                                    TextField(
                                        "",
                                        text: Binding(
                                            get: {
                                                String(format: "%02d", workouts[index].duration % 60)
                                            },
                                            set: { newValue in
                                                if let intValue = Int(newValue){
                                                    if intValue == 0{
                                                        let updatedWorkout = presetManager.updateWorkoutDuration(
                                                            currentWorkout: workouts[index],
                                                            minutes: workouts[index].duration / 60,
                                                            seconds: 1
                                                            )
                                                        
                                                    }
                                                    
                                                    else if intValue > 0, intValue <= 99{
                                                        
                                                        let updatedWorkout = presetManager.updateWorkoutDuration(
                                                            currentWorkout: workouts[index],
                                                            minutes: workouts[index].duration / 60,
                                                            seconds: intValue
                                                        )
                                                        workouts[index] = updatedWorkout
                                                    }
                                                }
                                            }
                                        )
                                    )
                                    .keyboardType(.numberPad)
                                    .foregroundColor(appearanceManager.fontColor)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .frame(width: 40, alignment: .trailing)
                                    .multilineTextAlignment(.trailing)
                                    
                                }
                                
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .background(Color.clear)
                            .swipeActions {
                                Button(role: .destructive) {
                                    workouts.remove(at: index)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        
                        Button(action: {
                            let newWorkout = Workout(name: "", duration: 1)
                            workouts.append(newWorkout)
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                    .foregroundColor(appearanceManager.fontColor)
                                Text("Add workout")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                .background(appearanceManager.backgroundColor)
                .onAppear {
                    if workouts.isEmpty {
                        workouts.append(presetManager.createWorkout(name: "Starts in...", duration: 5))
                    }
                }
            }
            
            Spacer()
            
            HStack {
                ZStack(alignment: .leading) {
                    if presetName.isEmpty {
                        Text("Name")
                            .foregroundColor(.gray)
                            .bold()
                            .padding(.leading, 10)
                    }
                    TextField("", text: $presetName)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(appearanceManager.fontColor)
                        .padding(.leading, 10)
                }
                .frame(height: 50)
                
                Spacer()
                
                Button(action: {
                    //presetManager.addPreset(name: presetName, workouts: workouts)
                    saveChanges()
                    selectedTab = 0
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Save")
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .foregroundColor(presetName.isEmpty ? .gray : .black)
                    .background(presetName.isEmpty ? Color.gray.opacity(0.6) : Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                    .cornerRadius(8)
                }
                .disabled(presetName.isEmpty)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal)
            
        }
    }
    
    //
    //    private func clearModal() {
    //        workoutName = ""
    //        workoutMinutes = 1
    //        workoutSeconds = 0
    //        isShowingWorkoutModal = false
    //    }
    //
    //    private func saveWorkout() {
    //        guard !workoutName.isEmpty, workoutMinutes > 0 || workoutSeconds > 0 else { return }
    //        let totalDuration = workoutMinutes * 60 + workoutSeconds
    //        let newWorkout = Workout(name: workoutName, duration: totalDuration) // Save raw duration
    //        workouts.append(newWorkout)
    //        clearModal()
    //    }
    private func calculateTotalDuration() -> String {
        let totalSeconds = workouts.reduce(0) { $0 + $1.duration }
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    private func saveChanges() {
        if let preset = selectedPreset {
            // Update existing preset
            presetManager.updatePreset(preset: preset, workouts: workouts, name: presetName)
        } else {
            // Create a new preset
            presetManager.addPreset(name: presetName, workouts: workouts)
        }
    }
}
