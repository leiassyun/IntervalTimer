import SwiftUI

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
        if hasDefaultState { return false }
        if initialPresetName != presetName { return true }
        if initialWorkouts.count != workouts.count { return true }
        
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
                    .padding(.bottom, 20)
                
                VStack(spacing: 0) {
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
                                    print("DEBUG: Delete button tapped for workout \(index)")
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
                            print("DEBUG: Moving workout from index \(source.first!) to \(destination)")
                            withAnimation(.default.speed(2.0)) {
                                workouts.move(fromOffsets: source, toOffset: destination)
                            }
                        }
                        
                        AddWorkoutButton(
                            workouts: $workouts,
                            focusedWorkoutIndex: $focusedWorkoutIndex
                        )
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(.active))
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
                    AppButton(
                        title: "Back",
                        icon: "chevron.left",
                        type: .secondary,
                        isFullWidth: false
                    ) {
                        handleBack()
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
