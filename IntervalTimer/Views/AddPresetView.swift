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

private struct WorkoutListView: View {
    @Binding var workouts: [Workout]
    @Binding var showingTimePicker: Bool
    @Binding var selectedWorkoutIndex: Int?
    @FocusState.Binding var focusedWorkoutIndex: Int?
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        List {
            ForEach(Array(workouts.enumerated()), id: \.element.id) { index, _ in
                WorkoutRowView(
                    index: index,
                    workout: $workouts[index],
                    showingTimePicker: $showingTimePicker,
                    selectedWorkoutIndex: $selectedWorkoutIndex,
                    focusedWorkoutIndex: $focusedWorkoutIndex
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        withAnimation {
                            guard index < workouts.count else { return }
                            workouts.remove(at: index)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .onMove { source, destination in
                withAnimation(.default.speed(2.0)) {
                    workouts.move(fromOffsets: source, toOffset: destination)
                }
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(.active))
    }
}

private struct AddWorkoutButton: View {
    @Binding var workouts: [Workout]
    @FocusState.Binding var focusedWorkoutIndex: Int?
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        Button(action: {
            let newWorkout = Workout(name: "", duration: 60)
            workouts.append(newWorkout)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedWorkoutIndex = workouts.count - 1
            }
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

struct AddPresetView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var presetManager: PresetManager
    @Binding var selectedTab: Int
    @State private var selectedPreset: Preset?
    @State private var showingTimePicker = false
    @State private var selectedWorkoutIndex: Int?
    @State private var showingDiscardAlert = false
    
    @State private var initialPresetName: String
    @State private var initialWorkouts: [Workout]
    @State private var presetName = ""
    @State private var workouts: [Workout] = []
    @FocusState private var focusedWorkoutIndex: Int?
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
        workouts[0].duration == 60 &&
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
            VStack(spacing: 0) {
                PresetHeaderView(totalDuration: calculateTotalDuration())
                
                Spacer().frame(height: 20)
                
                VStack(spacing: 0) {
                    WorkoutListView(
                        workouts: $workouts,
                        showingTimePicker: $showingTimePicker,
                        selectedWorkoutIndex: $selectedWorkoutIndex,
                        focusedWorkoutIndex: $focusedWorkoutIndex
                    )
                    
                    AddWorkoutButton(
                        workouts: $workouts,
                        focusedWorkoutIndex: $focusedWorkoutIndex
                    )
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                }
                .background(appearanceManager.backgroundColor)
                
                Spacer()
                
                PresetBottomBarView(presetName: $presetName) {
                    saveChanges()
                    selectedTab = 0
                }
            }
            .background(appearanceManager.backgroundColor)
            .onAppear {
                if workouts.isEmpty {
                    workouts.append(presetManager.createWorkout(name: "Starts in...", duration: 60))
                }
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
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                            Text("Back")
                                .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                        }
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


extension Workout: Equatable {
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.duration == rhs.duration
    }
}
