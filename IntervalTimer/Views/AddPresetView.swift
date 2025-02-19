import SwiftUI

struct AddPresetView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var presetManager: PresetManager
    
    @Binding var selectedTab: Int
    @State private var selectedPreset: Preset?
    @State private var showingTimePicker = false
    @State private var selectedWorkoutIndex: Int?
    @State private var showingDiscardAlert = false
    @State private var isEditing = false

    @State private var initialPresetName: String
    @State private var initialWorkouts: [Workout]
    @State private var presetName = ""
    @State private var workouts: [Workout] = []
    
    @FocusState private var focusedWorkoutIndex: Int?
    @Environment(\.dismiss) var dismiss
    
    init(selectedPreset: Binding<Preset?>, selectedTab: Binding<Int>) {
        _selectedPreset = State(initialValue: selectedPreset.wrappedValue)
        _selectedTab = selectedTab
        
        if let preset = selectedPreset.wrappedValue {
            _presetName = State(initialValue: preset.name)
            _workouts = State(initialValue: preset.workouts)
            _initialPresetName = State(initialValue: preset.name)
            _initialWorkouts = State(initialValue: preset.workouts)
        } else {
            _presetName = State(initialValue: "")
            _workouts = State(initialValue: [])
            _initialPresetName = State(initialValue: "")
            _initialWorkouts = State(initialValue: [])
        }
    }
    
    private var hasDefaultState: Bool {
        return workouts.count == 1 &&
            workouts[0].name == "Starts in..." &&
            workouts[0].duration == 5 &&
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
    
    private var workoutListContent: some View {
        ForEach(Array(workouts.enumerated()), id: \.element.id) { index, workout in
            HStack(spacing: 12) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(.gray)
                    .frame(width: 20)
                    .padding(.leading, 16)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isEditing.toggle()
                        }
                    }
                
                TextField("Session name", text: $workouts[index].name)
                    .font(.system(.title3, weight: .semibold))
                    .foregroundColor(appearanceManager.fontColor)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 5)
                    .focused($focusedWorkoutIndex, equals: index)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button(action: {
                    selectedWorkoutIndex = index
                    showingTimePicker = true
                }) {
                    Text(formatDuration(workout.duration))
                        .foregroundColor(appearanceManager.fontColor)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .padding(.horizontal)
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(appearanceManager.backgroundColor)
            .frame(maxWidth: .infinity)
            .background(appearanceManager.backgroundColor)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    withAnimation {
                        workouts.remove(at: index)
                        updateChange()
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
            }
        }
        .onMove { source, destination in
            guard isEditing else { return }
            withAnimation {
                workouts.move(fromOffsets: source, toOffset: destination)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                PresetHeaderView(totalDuration: calculateTotalDuration())
                    .padding(.bottom, 20)
                    .background(appearanceManager.backgroundColor.ignoresSafeArea())
                
                VStack(spacing: 0) {
                    List {
                        workoutListContent
                        AddWorkoutButton(
                            workouts: $workouts,
                            focusedWorkoutIndex: $focusedWorkoutIndex
                        )
                    }
                    .scrollContentBackground(.hidden)
                    .listRowSeparator(.hidden)
                    .listStyle(.plain)
                    .environment(\.editMode, Binding<EditMode>(
                        get: { isEditing ? .active : .inactive },
                        set: { _ in }
                    ))
                }
                .background(appearanceManager.backgroundColor)
                
                Spacer()
                
                PresetBottomBarView(presetName: $presetName, workouts: $workouts) {
                    saveChanges()
                    dismiss()
                    selectedTab = 0
                }
            }
            .background(appearanceManager.backgroundColor.ignoresSafeArea())
            .onAppear {
                if workouts.isEmpty {
                    workouts.append(presetManager.createWorkout(name: "Starts in...", duration: 5))
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
                        type: .textOnly,
                        isFullWidth: false,
                        action: handleBack
                    )
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
        .navigationViewStyle(StackNavigationViewStyle())
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
    
    private func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func updateChange() {
        print("Workout changes updated locally.")
    }
    
    private func saveChanges() {
        if let preset = selectedPreset {
            presetManager.updatePreset(preset: preset, workouts: workouts, name: presetName)
        } else {
            presetManager.addPreset(name: presetName, workouts: workouts)
        }
    }
}

extension Workout: Equatable {
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.duration == rhs.duration
    }
}
