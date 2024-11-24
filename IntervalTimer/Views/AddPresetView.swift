import SwiftUI

struct AddPresetView: View {
    @ObservedObject var presetManager: PresetManager

    @Environment(\.dismiss) var dismiss // To dismiss the view
    @State private var presetName = "" // State for preset name
    @State private var isShowingWorkoutModal = false // Controls whether the workout modal is shown
    @State private var workouts: [(name: String, duration: Int)] = [] // List of added workouts

    // States for workout modal
    @State private var workoutName = "" // State for workout name in modal
    @State private var workoutMinutes = 1 // Minutes input for workout duration
    @State private var workoutSeconds = 0 // Seconds input for workout duration
    @FocusState private var isWorkoutNameFocused: Bool // Tracks focus for workout name

    var body: some View {
        VStack(alignment: .leading) {
            // Preset Name Section
            ZStack(alignment: .leading) {
                if presetName.isEmpty {
                    Text("Preset name") // Placeholder text
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
            .padding(.top) // Add space at the top
            .background(Color.black) // Background matches the rest of the view

            Spacer().frame(height: 20) // Add some space below the Preset Name

            // List of Added Workouts
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(workouts.indices, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(workouts[index].name)")
                                        .foregroundColor(.white)
                                        //.font(.headline)
                                        .font(.system(size: 24, weight: .bold))

                                    
                                    
                                    Spacer() // Pushes the next Text to the right
                                    
                                    Text(formatDuration(workouts[index].duration))
                                        .foregroundColor(.white)
                                        //.font(.headline)
                                        .font(.system(size: 24, weight: .bold)) // Bigger font size for name

                                }
                            }
                            Spacer()
//                            Button(action: {
//                                // Remove workout
//                                workouts.remove(at: index)
//                            }) {
//                                Image(systemName: "trash")
//                                    .foregroundColor(.red)
//                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        //.background(Color.gray.opacity(0.2))
                        //.cornerRadius(8)
                        //.padding(.horizontal)
                    }

                    // Add Workout Button (Placed dynamically after the list)
                    Button(action: {
                        isShowingWorkoutModal = true // Show workout modal
                    }) {
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
        .navigationTitle("") // Clear navigation bar title
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let newPreset = Preset(
                        name: presetName.isEmpty ? "Untitled" : presetName,
                        workoutDuration: 0, // Default value for entire preset duration
                        restDuration: 0,
                        repeatCount: 0
                    )
                    presetManager.presets.append(newPreset)
                    dismiss()
                }
                .disabled(presetName.isEmpty)
                .foregroundColor(presetName.isEmpty ? .gray : .green)
            }
        }
        .sheet(isPresented: $isShowingWorkoutModal) {
            // Workout Modal View
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
                                    if newValue > 59 { workoutMinutes = 59 } // Clamp to max 59 minutes
                                    if newValue < 0 { workoutMinutes = 0 }  // Clamp to min 0 minutes
                                }

                            Text(":") // Separator
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
                                    if newValue > 59 { workoutSeconds = 59 } // Clamp to max 59 seconds
                                    if newValue < 0 { workoutSeconds = 0 }  // Clamp to min 0 seconds
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
                            isShowingWorkoutModal = false // Dismiss the modal
                        }
                        .foregroundColor(.red)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            // Save the workout and dismiss the modal
                            if !workoutName.isEmpty && (workoutMinutes > 0 || workoutSeconds > 0) {
                                let totalDuration = workoutMinutes * 60 + workoutSeconds
                                workouts.append((name: workoutName, duration: totalDuration))
                                workoutName = "" // Clear fields for next use
                                workoutMinutes = 1
                                workoutSeconds = 0
                                isShowingWorkoutModal = false
                            }
                        }
                        .foregroundColor((workoutName.isEmpty || (workoutMinutes == 0 && workoutSeconds == 0)) ? .gray : .green)
                        .disabled(workoutName.isEmpty || (workoutMinutes == 0 && workoutSeconds == 0))
                    }
                }
                .onAppear {
                    // Automatically focus the workout name TextField
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isWorkoutNameFocused = true
                    }
                }
            }
            .presentationDetents([.fraction(0.5)]) // Set modal height to half the screen
            .presentationDragIndicator(.visible) // Show a drag indicator
        }
    }

    // Helper function to format duration into MM:SS format
    private func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
