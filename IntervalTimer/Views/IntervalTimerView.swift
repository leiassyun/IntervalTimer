import SwiftUI

struct IntervalTimerView: View {
    let preset: Preset?

    @State private var currentWorkoutIndex = 0
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var remainingTime: TimeInterval = 0
    @State private var isPlaying = false
    @State private var timer: Timer? = nil
    @State private var backgroundTask: UIBackgroundTaskIdentifier = .invalid


    var body: some View {
        VStack {
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
                        .foregroundColor(appearanceManager.fontColor)
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
                .foregroundColor(appearanceManager.fontColor)
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
        .background(appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)

        .onAppear {
            startWorkout()
            setTabBarVisibility(hidden: true)
        }
        .onDisappear {
            stopTimer()
            setTabBarVisibility(hidden: false)
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

        startBackgroundTask() // Start background task

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
        endBackgroundTask() // End background task
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
    private func startBackgroundTask() {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "IntervalTimer") {
                // Called when the background time is about to expire
                endBackgroundTask()
            }
        }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    // MARK: - Time Formatting

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    private func setTabBarVisibility(hidden: Bool) {
        if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
            tabBarController.tabBar.isHidden = hidden
        }
    }
}
