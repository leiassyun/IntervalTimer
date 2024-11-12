import SwiftUI
struct WorkoutTestView: View {
    @StateObject private var workoutManager = WorkoutManager(workoutInterval: 30, restInterval: 15, repeatCount: 5)
    
    @State private var totalSetsInput: String = ""
    @State private var restTimeInput: String = ""
    @State private var exerciseTimeInput: String = ""
    @State private var isTextFieldDisabled: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Text("Workout Timer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            VStack(spacing: 15) {
                Section(header: Text("Set Workout Parameters").font(.headline).padding(.bottom, 10).padding(.top)) {
                    HStack {
                        Text("Total Sets:")
                        TextField("Number of Sets", text: $totalSetsInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .disabled(isTextFieldDisabled)
                    }
                    
                    HStack {
                        Text("Exercise Time (s):")
                        TextField("Exercise Time", text: $exerciseTimeInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .disabled(isTextFieldDisabled)
                    }
                    
                    HStack {
                        Text("Rest Time (s):")
                        TextField("Rest Time", text: $restTimeInput)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                            .disabled(isTextFieldDisabled)
                    }
                    
                    // Start Workout Button
                    Button(action: {
                        if let exerciseTime = Double(exerciseTimeInput),
                           let restTime = Double(restTimeInput),
                           let totalSets = Int(totalSetsInput) {
                            workoutManager.stop() // Stop any running timers before starting a new workout
                            workoutManager.workoutInterval = exerciseTime
                            workoutManager.restInterval = restTime
                            workoutManager.repeatCount = totalSets
                            workoutManager.start()
                            isTextFieldDisabled = true // Freeze the text fields after setting parameters
                        }
                    }) {
                        Text("Start Workout")
                            .font(.title2)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            VStack {
                Text("Time Remaining: \(Int(workoutManager.timeRemaining))")
                    .font(.largeTitle)
                    .padding()
                
                HStack(spacing: 30) {
                    Button(action: {
                        if workoutManager.isFinished {
                            workoutManager.start()
                        } else {
                            workoutManager.stop()
                            isTextFieldDisabled = false
                        }
                    }) {
                        Text(workoutManager.isFinished ? "Restart" : "Stop")
                            .padding()
                            .background(workoutManager.isFinished ? Color.green : Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                
                HStack {
                    Text("Sets Remaining: \(workoutManager.repeatCount - workoutManager.currentSets)")
                        .font(.title3)
                    Text(workoutManager.isExercisePhase ? "WORKOUT" : "REST")
                        .font(.title3)
                        .padding()
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}

struct WorkoutTestView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutTestView()
    }
}
