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
                        .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                }
                Spacer()
                Button(action: {
                    stopTimer()
                    dismiss()
                }) {
                    Text("Hold to exit")
                        .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                        .padding(15)
                        .background(
                               RoundedRectangle(cornerRadius: 15)
                                   .fill(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 0.15)))
                           )
                }
                Spacer()
                Button(action: {
                    skipToNextWorkout()
                }) {
                    Image(systemName: "arrow.forward.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
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
                        .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
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
                Image(systemName: isPlaying ? "pause.fill" : "play.fill") // Dynamically switch between play/pause
                    .resizable() // Enable resizing
                    .scaledToFit() // Maintain aspect ratio
                    .frame(width: 40, height: 40) // Set the icon size
                    .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1))) // Bright green icon
            }
            .frame(width: 80, height: 80) // Set the overall button size
            .background(
                Circle()
                    .fill(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 0.15))) // Semi-transparent background
            )

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

        if currentWorkoutIndex < preset.workouts.count && currentWorkoutIndex > 0 {
            remainingTime = Double(preset.workouts[currentWorkoutIndex].duration)
        } else {
            // All workouts complete
            stopTimer()
        }
    }

    private func skipToNextWorkout() {
        guard let preset = preset, currentWorkoutIndex < preset.workouts.count - 1 else {
               return
           }
        stopTimer()
        moveToNextWorkout()
        // startWorkout()
        if isPlaying {
            startWorkout()
        }
        
    }

    private func goBackToPrevWorkout() {
        guard currentWorkoutIndex > 0 else {
                return
            }
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
