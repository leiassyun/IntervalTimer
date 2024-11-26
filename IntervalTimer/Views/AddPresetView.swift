import SwiftUI

struct AddPresetView: View {
    @ObservedObject var presetManager: PresetManager
    @Binding var selectedTab: Int

    @Environment(\.dismiss) var dismiss
    @State private var presetName = ""
    @State private var workouts: [Workout] = []

    // States for workout modal
    @State private var isShowingWorkoutModal = false
    @State private var workoutName = ""
    @State private var workoutMinutes = 1
    @State private var workoutSeconds = 0
    @FocusState private var isWorkoutNameFocused: Bool

    var body: some View {
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
                    .foregroundColor(.white)
                    .padding(.leading)
            }
            .padding(.top)
            .background(Color.black)

            Spacer().frame(height: 20)

            // List of Workouts
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(workouts) { workout in
                        HStack {
                           
                            Text(workout.name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .bold))
                            Spacer()
                                Text(workout.fDuration)
                                    .foregroundColor(.white)
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
                                .foregroundColor(.white)
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
        .background(Color.black.edgesIgnoringSafeArea(.all))
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
        .sheet(isPresented: $isShowingWorkoutModal) {
            // Workout Modal Content
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
                            .focused($isWorkoutNameFocused) // Attach focus state
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top)

                    // Workout Duration Input (Minute:Second Format)
                    VStack(alignment: .center, spacing: 8) {
                        Text("Count")
                            .foregroundColor(.gray)
                            .font(.headline)
                            .padding(.horizontal)

                        HStack {
                            // Minutes Input
                            TextField("00", value: $workoutMinutes, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.largeTitle)
                                .frame(width: 60)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onChange(of: workoutMinutes) { newValue in
                                    if newValue > 59 { workoutMinutes = 59 }
                                    if newValue < 0 { workoutMinutes = 0 }
                                }

                            Text(":")
                                .font(.largeTitle)
                                .foregroundColor(.white)

                            // Seconds Input
                            TextField("00", value: $workoutSeconds, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.largeTitle)
                                .frame(width: 60)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onChange(of: workoutSeconds) { newValue in
                                    if newValue > 59 { workoutSeconds = 59 }
                                    if newValue < 0 { workoutSeconds = 0 }
                                }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)

                    Spacer()
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isWorkoutNameFocused = true
                    }
                }
            }
            .presentationDetents([.fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
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
