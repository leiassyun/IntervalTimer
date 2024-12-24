import SwiftUI

struct AddPresetView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @ObservedObject var presetManager: PresetManager
    @Binding var selectedTab: Int
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
        _presetManager = ObservedObject(wrappedValue: presetManager)
        _selectedTab = selectedTab
    }
    var body: some View {
        ZStack {
            // Main content of AddPresetView
            VStack(alignment: .leading, spacing: 10) {
                // Preset Name Section
                ZStack(alignment: .leading) {
                    if presetName.isEmpty {
                        Text("Preset name")
                            .foregroundColor(.gray)
                            .font(.largeTitle)
                            .bold()
                            .padding(.leading)
                    }
                    TextField("", text: $presetName)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(appearanceManager.fontColor)
                        .padding(.leading)
                }
                .padding(.top)
                .background(appearanceManager.backgroundColor)
                
                Spacer().frame(height: 20)
                
                // List of Workouts
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(workouts) { workout in
                            HStack {
                                Text(workout.name)
                                    .foregroundColor(appearanceManager.fontColor)
                                    .font(.system(size: 24, weight: .bold))
                                Spacer()
                                Text(workout.fDuration)
                                    .foregroundColor(appearanceManager.fontColor)
                                    .font(.system(size: 24, weight: .bold))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                        
                        // Add Workout Button
                        Button(action: { isShowingWorkoutModal = true }) {
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
                
                Spacer()
            }
            .background(appearanceManager.backgroundColor)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreset()
                    }
                    .disabled(presetName.isEmpty)
                    .foregroundColor(presetName.isEmpty ? .gray : .green)
                }
            }
            
            // Add overlay behind the sheet
            if isShowingWorkoutModal {
                Color(UIColor(red: 91/255, green: 76/255, blue: 113/255, alpha: 0.9))
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .sheet(isPresented: $isShowingWorkoutModal) {
            // Content of the modal sheet
            ZStack {
                NavigationView {
                    VStack {
                        // Workout Name Input
                        ZStack(alignment: .leading) {
                            if workoutName.isEmpty {
                                Text("Workout name")
                                    .foregroundColor(.gray)
                                    .font(.title)
                                    .padding(.horizontal, 8)
                            }
                            TextField("", text: $workoutName)
                                .focused($isWorkoutNameFocused)
                                .font(.title)
                                .foregroundColor(appearanceManager.fontColor)
                                .padding()
                        }
                        
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.top)
                        Spacer()
                        
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Count")
                                .foregroundColor(.white)
                                .font(.system(size: 25, weight: .bold))
                                .padding(.horizontal)
                            
                            HStack(spacing: 4) { // Remove spacing between elements
                                // Minutes Input
                                TextField(
                                    "",
                                        text: Binding(
                                            get: {
                                                convertTimes(minutes: workoutMinutes, seconds: workoutSeconds).formattedMinutes
                                            },
                                            set: { newValue in
                                                if let intValue = Int(newValue), intValue >= 0 {
                                                    let totalSeconds = (intValue * 60) + workoutSeconds
                                                    let converted = convertTimes(minutes: intValue, seconds: workoutSeconds)
                                                    workoutMinutes = min(converted.totalSeconds / 60, 99) // Cap at 99 minutes
                                                    workoutSeconds = converted.totalSeconds % 60
                                                }
                                            }
                                    )
                                )
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .frame(minWidth: 40, maxWidth: 80, alignment: .trailing)
                                .multilineTextAlignment(.trailing)
                                
                                // Colon
                                Text(":")
                                    .foregroundColor(.white)
                                    .font(.system(size: 60, weight: .bold))
                                //.padding(.horizontal, 4)
                                
                                // Seconds Input
                                TextField(
                                    "00",
                                    text: Binding(
                                        get: {
                                            convertTimes(minutes: workoutMinutes, seconds: workoutSeconds).formattedSeconds
                                        },
                                        set: { newValue in
                                            if let intValue = Int(newValue), intValue >= 0 {
                                                let totalSeconds = workoutMinutes * 60 + intValue
                                                workoutMinutes = min(totalSeconds / 60, 99) // Update minutes and cap at 99
                                                workoutSeconds = totalSeconds % 60 // Update seconds
                                            }
                                        }
                                    )
                                )
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .frame(minWidth: 40, maxWidth: 80, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            
                        }
                        Spacer()
                        
                    }
                    .background(appearanceManager.backgroundColor)
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                clearModal()
                            }
                            .foregroundColor(.red)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                saveWorkout()
                            }
                            .foregroundColor(workoutName.isEmpty || (workoutMinutes == 0 && workoutSeconds == 0) ? .gray : .green)
                            .disabled(workoutName.isEmpty || (workoutMinutes == 0 && workoutSeconds == 0))
                        }
                    }
                    .onAppear {
                        isOverlayVisible = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isWorkoutNameFocused = true
                        }
                    }
                    .onDisappear {
                        isOverlayVisible = false
                    }
                }
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
    }
    
    func convertTimes(minutes: Int, seconds: Int) -> (formattedMinutes: String, formattedSeconds: String, totalSeconds: Int) {
        let totalSeconds = min((minutes * 60) + seconds, 99 * 60 + 59) // Cap at 99:59
        let calculatedMinutes = totalSeconds / 60
        let calculatedSeconds = totalSeconds % 60
        return (
            formattedMinutes:String(format: "%02d", calculatedMinutes),
            formattedSeconds: String(format: "%02d", calculatedSeconds), // Always 2 digits for seconds
            totalSeconds: totalSeconds
        )
    }
    private func savePreset() {
        let totalDuration = workouts.reduce(0) { $0 + $1.duration }
        let newPreset = Preset(
            name: presetName.isEmpty ? "Untitled" : presetName,
            workouts: workouts,
            totalDuration: totalDuration
        )
        presetManager.presets.append(newPreset)
        presetName = ""
        workouts = []
        selectedTab = 0
        dismiss()
    }
    
    private func clearModal() {
        workoutName = ""
        workoutMinutes = 1
        workoutSeconds = 0
        isShowingWorkoutModal = false
    }
    
    private func saveWorkout() {
        guard !workoutName.isEmpty, workoutMinutes > 0 || workoutSeconds > 0 else { return }
        let totalDuration = workoutMinutes * 60 + workoutSeconds
        let newWorkout = Workout(name: workoutName, duration: totalDuration) // Save raw duration
        workouts.append(newWorkout)
        clearModal() // Reset modal state
    }
}
