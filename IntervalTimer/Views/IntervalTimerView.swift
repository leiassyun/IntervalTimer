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
    @State private var showControlButtons = false
    
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    goBackToPrevWorkout()
                }) {
                    Image(systemName: "backward.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 0.15)))
                        )
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
                    Image(systemName: "forward.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 0.15)))
                        )
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
                }          
            }
            
            // Timer Display
            Text(formatTime(remainingTime))
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundColor(appearanceManager.fontColor)
                .padding()
            
            
            HStack{
                Spacer()
                VStack{
                    if let preset = preset{
                        if currentWorkoutIndex < preset.workouts.count{
                            Text("\(currentWorkoutIndex + 1) of \(preset.workouts.count)")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.gray)
                        } else {
                            Text("\(currentWorkoutIndex) of \(preset.workouts.count)")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.gray)
                            
                        }
                    }
                    Text("Intervals")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                    
                    
                }
                Spacer()
                VStack{
                    if let preset = preset {
                        
                        Text("\(formatTime(calculateRemainingWorkoutTime()))")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray)
                        Text("Remaining")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.gray)
                    }
                    
                    
                }
                Spacer()
            }
            Spacer()
            
            VStack{
                if let preset = preset {
                    if currentWorkoutIndex == preset.workouts.count && calculateRemainingWorkoutTime() == 0 {
                        Button(action: {
                            dismiss()
                            
                        }) {
                            Text("Complete")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 110, height: 45)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                                )

                                
                        }
                    }
                    else if showControlButtons {
                        VStack {
                            Spacer()
                            Button(action: {
                                startWorkout()
                                showControlButtons = false
                                
                            }) {
                                Text("Resume")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: 110, height: 45)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                                    )

                                    
                            }
                            Button(action: {
                                restartWorkout()
                                showControlButtons = false
                            }) {
                                Text("Restart")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            }
                            
                            .padding(.bottom, 40)
                        }
                    }
                    else{
                        Text("Tap anywhere to pause")
                            .font(.subheadline)
                            .foregroundStyle(appearanceManager.fontColor)
                    }
                }
                
                
            }
            .frame(height: 100)
            .animation(.easeInOut, value: showControlButtons)
           
        }
      
        .contentShape(Rectangle())
        .onTapGesture {
            showControlButtons.toggle()
            stopTimer()
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
    private func calculateRemainingWorkoutTime() -> TimeInterval {
        guard let preset = preset else { return 0 }
        let remainingIntervals = preset.workouts[currentWorkoutIndex...]
        let remainingWorkoutsTime = remainingIntervals.dropFirst().reduce(0) { $0 + Double($1.duration) }
        return remainingTime + remainingWorkoutsTime
    }
    
    private func startWorkout() {
        guard let preset = preset, currentWorkoutIndex < preset.workouts.count else {
            return
        }
        
        isPlaying = true
        
        if remainingTime == 0 {
            let currentWorkout = preset.workouts[currentWorkoutIndex]
            remainingTime = Double(currentWorkout.duration)
        }
        
        startBackgroundTask()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                moveToNextWorkout()
            }
        }
    }
    private func restartWorkout() {
        guard let preset = preset, currentWorkoutIndex < preset.workouts.count else {
            return
        }
        currentWorkoutIndex = 0
        let currentWorkout = preset.workouts[currentWorkoutIndex]
        remainingTime = Double(currentWorkout.duration)
        startWorkout()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
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
            stopTimer()
        }
    }
    private func moveToPrevWorkout() {
        guard let preset = preset else { return }
        currentWorkoutIndex -= 1
        if currentWorkoutIndex < preset.workouts.count && currentWorkoutIndex > 0 {
            remainingTime = Double(preset.workouts[currentWorkoutIndex].duration)
        } else {
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
