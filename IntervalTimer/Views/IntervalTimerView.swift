import SwiftUI
import AVFoundation

struct IntervalTimerView: View {
    let preset: Preset?
    @StateObject private var timerManager = TimerManager()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showControlButtons = false
    @State private var lastPlayedNumber: Int = 0
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    var body: some View {
        VStack {
            // Top Control Bar
            HStack {
                AppButton(
                    title: "",
                    icon: "backward.fill",
                    type: .secondary,
                    isFullWidth: false
                ) {
                    Task { @MainActor in
                        await timerManager.moveToPreviousWorkout()
                    }
                }
                
                Spacer()
                
                AppButton(
                    title: "Hold to exit",
                    type: .secondary,
                    isFullWidth: false
                ) {
                    Task { @MainActor in
                        await timerManager.stopTimer()
                        dismiss()
                    }
                }
                
                Spacer()
                
                AppButton(
                    title: "",
                    icon: "forward.fill",
                    type: .secondary,
                    isFullWidth: false
                ) {
                    Task { @MainActor in
                        await timerManager.moveToNextWorkout()
                    }
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
                    .onChange(of: timerManager.currentWorkoutIndex) { newValue in
                        Task { @MainActor in
                            let currentWorkoutName = preset.workouts[newValue].name
                            speakWorkoutName(currentWorkoutName)
                        }
                    }
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
                    AppButton(
                        title: "Complete",
                        type: .primary,
                        isFullWidth: false
                    ) {
                        dismiss()
                    }
                    .padding(.horizontal)
                } else if showControlButtons {
                    VStack(spacing: 16) {
                        AppButton(
                            title: "Resume",
                            type: .primary,
                            isFullWidth: true
                        ) {
                            Task { @MainActor in
                                await timerManager.startTimer()
                                showControlButtons = false
                            }
                        }
                        
                        AppButton(
                            title: "Restart",
                            type: .tertiary,
                            isFullWidth: true
                        ) {
                            Task { @MainActor in
                                await timerManager.resetToStart()
                                await timerManager.startTimer()
                                showControlButtons = false
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                } else {
                    Text("Tap anywhere to pause")
                        .font(.subheadline)
                        .foregroundStyle(appearanceManager.fontColor)
                }
            }
            .frame(height: 150)
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
                    SoundManager.shared.playSound(named: "timerComplete")
                }
                timerManager.onTimerTick = { remainingTime in
                    let seconds = Int(remainingTime)
                    if seconds <= 5 && seconds > 0 && seconds != lastPlayedNumber {
                        lastPlayedNumber = seconds
                        SoundManager.shared.playSound(named: String(seconds))
                    }
                }
                Task { @MainActor in
                    if let firstWorkout = preset.workouts.first {
                        timerManager.setRemainingTime(Double(firstWorkout.duration))
                        speakWorkoutName(firstWorkout.name)

                    }
                    await timerManager.startTimer()
                }
                setTabBarVisibility(hidden: true)
            }
        }
        .onDisappear {
            Task { @MainActor in
                await timerManager.stopTimer()
                SoundManager.shared.stopSound()
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
    private func speakWorkoutName(_ name: String) {
        guard !name.isEmpty else {
            print("Workout name is empty. Skipping speech.")
            return
        }
        let language: String
        if name.range(of: "\\p{Hangul}", options: .regularExpression) != nil {
            language = "ko-KR"
        } else {
            language = "en-US"
        }
        let utterance = AVSpeechUtterance(string: name)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
    
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
        
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        speechSynthesizer.speak(utterance)
        print("Speaking workout name: \(name) in language: \(language)")
    }
}
