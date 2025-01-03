import SwiftUI
import AVFoundation

struct IntervalTimerView: View {
    let preset: Preset?
    @StateObject private var timerManager = TimerManager()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showControlButtons = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    Task { @MainActor in
                        await timerManager.moveToPreviousWorkout()
                    }
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
                    Task { @MainActor in
                        await timerManager.stopTimer()
                        dismiss()
                    }
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
                    Task { @MainActor in
                        await timerManager.moveToNextWorkout()
                    }
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
            if let preset = preset, !preset.workouts.isEmpty {
                Text(preset.workouts[timerManager.currentWorkoutIndex].name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(appearanceManager.fontColor)
                    .padding()
            }
            
            // Timer Display
            Text(formatTime(timerManager.remainingTime))
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                .foregroundColor(appearanceManager.fontColor)
                .padding()
            
            // Progress Info
            if let preset = preset {
                HStack {
                    Spacer()
                    VStack {
                        Text("\(timerManager.currentWorkoutIndex + 1) of \(preset.workouts.count)")
                            .font(.system(.title3, weight: .bold))
                            .foregroundColor(.gray)
                        Text("Intervals")
                            .font(.system(.title3, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack {
                        Text("\(formatTime(calculateRemainingWorkoutTime(preset)))")
                            .font(.system(.title3, weight: .bold))
                            .foregroundColor(.gray)
                        Text("Remaining")
                            .font(.system(.title3, weight: .bold))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
            
            Spacer()
            
            // Control Buttons
            VStack {
                if timerManager.isWorkoutComplete {
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
                } else if showControlButtons {
                    VStack {
                        Spacer()
                        Button(action: {
                            Task { @MainActor in
                                await timerManager.startTimer()
                                showControlButtons = false
                            }
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
                            Task { @MainActor in
                                await timerManager.resetToStart()
                                await timerManager.startTimer()
                                showControlButtons = false
                            }
                        }) {
                            Text("Restart")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                        }
                        .padding(.bottom, 40)
                    }
                } else {
                    Text("Tap anywhere to pause")
                        .font(.subheadline)
                        .foregroundStyle(appearanceManager.fontColor)
                }
            }
            .frame(height: 100)
            .animation(.easeInOut, value: showControlButtons)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            showControlButtons.toggle()
            if showControlButtons {
                Task { @MainActor in
                    await timerManager.pauseTimer()
                }
            }
        }
        .background(appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            if let preset = preset {
                timerManager.workouts = preset.workouts
                timerManager.onWorkoutComplete = {
                    playSound()
                }
                Task { @MainActor in
                    if let firstWorkout = preset.workouts.first {
                        timerManager.setRemainingTime(Double(firstWorkout.duration))
                    }
                    await timerManager.startTimer()
                }
                setTabBarVisibility(hidden: true)
            }
        }
        .onDisappear {
            Task { @MainActor in
                await timerManager.stopTimer()
                stopSound()
                setTabBarVisibility(hidden: false)
            }
        }
    }
    
    private func calculateRemainingWorkoutTime(_ preset: Preset) -> TimeInterval {
        let remainingIntervals = preset.workouts[timerManager.currentWorkoutIndex...]
        let remainingWorkoutsTime = remainingIntervals.dropFirst().reduce(0) { $0 + Double($1.duration) }
        return timerManager.remainingTime + remainingWorkoutsTime
    }
    
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
    
    private func playSound() {
        guard let url = Bundle.main.url(forResource: "timerComplete", withExtension: "mp3") else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    
    private func stopSound() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
