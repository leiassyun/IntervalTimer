import SwiftUI

struct IntervalTimerView: View {
    let preset: Preset?

    @State private var currentWorkoutIndex = 0
    @Environment(\.dismiss) var dismiss
    @State private var remainingTime: TimeInterval = 0
    @State private var isPlaying = false
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            // Top Navigation Bar
            HStack {
                Button(action: {
                    goBackToPrevWorkout()
                    

                }) {
                    Image(systemName: "arrow.backward.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.green)
                }
                Spacer()
                Button(action: {
                    stopTimer()
                    dismiss()
                }) {
                    Text("Hold to exit")
                        .foregroundColor(.green)
                        .padding(10)
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.green, lineWidth: 2))
                }
                Spacer()
                Button(action: {
                    skipToNextWorkout()
                }) {
                    Image(systemName: "arrow.forward.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.green)
                }
            }
            .padding()

            Spacer()

            // Current Workout Name
            if let preset = preset {
                if currentWorkoutIndex < preset.workouts.count {
                    Text(preset.workouts[currentWorkoutIndex].name)
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                } else {
                    Text("Workout Complete!")
                        .font(.largeTitle)
                        .foregroundColor(.green)
                        .padding()
                }
            } else {
                Text("No Preset Selected")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            }

            // Timer Display
            Text(formatTime(remainingTime))
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)
                .padding()

            Spacer()

            // Play/Pause Button
            Button(action: {
                togglePlayPause()
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)

        .onAppear {
            startWorkout()
            
        }
        .onDisappear {
            stopTimer()
            
        }
    }
        

    // MARK: - Timer Logic

    private func startWorkout() {
        guard let preset = preset, currentWorkoutIndex < preset.workouts.count else {
            return
        }
        isPlaying = true

        let currentWorkout = preset.workouts[currentWorkoutIndex]
        remainingTime = Double(currentWorkout.duration)

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                moveToNextWorkout()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func togglePlayPause() {
        if isPlaying {
            stopTimer()
            
        } else {
            if timer == nil {
                        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                            if remainingTime > 0 {
                                remainingTime -= 1
                            } else {
                                moveToNextWorkout()
                            }
                        }
                    }
            
        }
        isPlaying.toggle()
    }

    private func moveToNextWorkout() {
        guard let preset = preset else { return }
        currentWorkoutIndex += 1

        if currentWorkoutIndex < preset.workouts.count {
            remainingTime = Double(preset.workouts[currentWorkoutIndex].duration)
        } else {
            // All workouts complete
            stopTimer()
        }
    }
    private func moveToPrevWorkout() {
        guard let preset = preset else { return }
        currentWorkoutIndex -= 1

        if currentWorkoutIndex < preset.workouts.count && currentWorkoutIndex > -1 {
            remainingTime = Double(preset.workouts[currentWorkoutIndex].duration)
        } else {
            // All workouts complete
            stopTimer()
        }
    }

    private func skipToNextWorkout() {
        stopTimer()
        moveToNextWorkout()
        // startWorkout()
        if isPlaying {
            startWorkout() // Auto start?
        }
        
    }

    private func goBackToPrevWorkout() {
        stopTimer()
        moveToPrevWorkout()
        if isPlaying {
            startWorkout()
        }
    }
    // MARK: - Time Formatting

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
