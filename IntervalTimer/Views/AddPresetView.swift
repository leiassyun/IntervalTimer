import SwiftUI

struct TimePickerView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            HStack {
                Picker("Minutes", selection: $minutes) {
                    ForEach(0...60, id: \.self) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                
                Text(":")
                    .font(.title2)
                    .bold()
                
                Picker("Seconds", selection: $seconds) {
                    ForEach(0...59, id: \.self) { second in
                        Text(String(format: "%02d", second)).tag(second)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddPresetView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var presetManager: PresetManager
    @Binding var selectedTab: Int
    @State private var selectedPreset: Preset?
    @State private var showingTimePicker = false
    @State private var selectedWorkoutIndex: Int?
    @State private var showingDiscardAlert = false
    
    // States for tracking changes
    @State private var initialPresetName: String
    @State private var initialWorkouts: [Workout]
    @State private var presetName = ""
    @State private var workouts: [Workout] = []
    
    @Environment(\.dismiss) var dismiss
    
    init(selectedPreset: Preset?, presetManager: PresetManager, selectedTab: Binding<Int>) {
        _selectedTab = selectedTab
        self.selectedPreset = selectedPreset
        _initialPresetName = State(initialValue: selectedPreset?.name ?? "")
        _initialWorkouts = State(initialValue: selectedPreset?.workouts ?? [])
        _presetName = State(initialValue: selectedPreset?.name ?? "")
        _workouts = State(initialValue: selectedPreset?.workouts ?? [])
    }
    
    private var hasDefaultState: Bool {
        return workouts.count == 1 &&
               workouts[0].name == "Starts in..." &&
               workouts[0].duration == 5 &&
               presetName.isEmpty
    }
    
    private var hasUnsavedChanges: Bool {
        if hasDefaultState {
            return false
        }
        
        if initialPresetName != presetName {
            return true
        }
        
        if initialWorkouts.count != workouts.count {
            return true
        }
        
        for (index, initialWorkout) in initialWorkouts.enumerated() {
            let currentWorkout = workouts[index]
            if initialWorkout.name != currentWorkout.name ||
               initialWorkout.duration != currentWorkout.duration {
                return true
            }
        }
        
        return false
    }
    
    private func handleBack() {
        if hasUnsavedChanges {
            showingDiscardAlert = true
        } else {
            dismiss()
            selectedTab = 0
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(spacing: 0) {
                    HStack {
                        Text("New Preset")
                            .font(.system(.title2, weight: .bold))
                            .foregroundColor(appearanceManager.fontColor)
                        Spacer()
                        Text("Total: \(calculateTotalDuration())")
                            .font(.system(.headline, weight: .bold))
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
                                        .font(.system(.title3, weight: .semibold))
                                        .foregroundColor(appearanceManager.fontColor)
                                        .textFieldStyle(PlainTextFieldStyle())
                                        .padding(.vertical, 5)
                                        .background(Color.clear)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        selectedWorkoutIndex = index
                                        showingTimePicker = true
                                    }) {
                                        Text(formatDuration(workouts[index].duration))
                                            .foregroundColor(appearanceManager.fontColor)
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .padding(.horizontal)
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
            .sheet(isPresented: $showingTimePicker) {
                if let index = selectedWorkoutIndex {
                    TimePickerView(
                        minutes: Binding(
                            get: { workouts[index].duration / 60 },
                            set: { newValue in
                                let updatedWorkout = presetManager.updateWorkoutDuration(
                                    currentWorkout: workouts[index],
                                    minutes: newValue,
                                    seconds: workouts[index].duration % 60
                                )
                                workouts[index] = updatedWorkout
                            }
                        ),
                        seconds: Binding(
                            get: { workouts[index].duration % 60 },
                            set: { newValue in
                                let updatedWorkout = presetManager.updateWorkoutDuration(
                                    currentWorkout: workouts[index],
                                    minutes: workouts[index].duration / 60,
                                    seconds: newValue
                                )
                                workouts[index] = updatedWorkout
                            }
                        )
                    )
                    .presentationDetents([.height(250)])
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: handleBack) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                        Text("Back")
                            .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                    }
                }
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Discard Changes", role: .destructive) {
                    dismiss()
                    selectedTab = 0
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("You have unsaved changes. Are you sure you want to leave this page?")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func calculateTotalDuration() -> String {
        let totalSeconds = workouts.reduce(0) { $0 + $1.duration }
        if totalSeconds < 60 {
            return "\(totalSeconds)s"
        } else {
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            return "\(minutes)m \(String(format: "%02d", seconds))s"
        }
    }
    
    private func saveChanges() {
        if let preset = selectedPreset {
            presetManager.updatePreset(preset: preset, workouts: workouts, name: presetName)
        } else {
            presetManager.addPreset(name: presetName, workouts: workouts)
        }
        dismiss()
    }
}

// Make Workout conform to Equatable
extension Workout: Equatable {
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.duration == rhs.duration
    }
}
