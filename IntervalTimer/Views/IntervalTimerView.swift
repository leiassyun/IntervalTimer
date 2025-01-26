import SwiftUI
import AVFoundation

private struct HoldToExitButton: View {
    let onComplete: () -> Void
    @State private var isHolding = false
    @State private var holdProgress: Double = 0
    private let holdDuration: Double = 1
    private let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    var body: some View {
        AppButton(
            title: "Hold to exit",
            type: .secondary,
            isFullWidth: false
        ) { }
        .overlay(
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    if isHolding {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppTheme.Colors.primary.opacity(0.3))
                            .frame(width: geometry.size.width * holdProgress)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .animation(.linear(duration: 0.1), value: holdProgress)
            }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isHolding {
                        isHolding = true
                    }
                }
                .onEnded { _ in
                    isHolding = false
                    holdProgress = 0
                }
        )
        .onReceive(timer) { _ in
            guard isHolding else { return }
            holdProgress = min(holdProgress + 0.01 / holdDuration, 1.0)
            if holdProgress >= 1.0 {
                isHolding = false
                holdProgress = 0
                onComplete()
            }
        }
    }
}

struct IntervalTimerView: View {
    let preset: Preset?
    @StateObject private var timerManager = TimerManager()
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var showControlButtons = false
    @State private var lastPlayedNumber: Int = 0
    @State private var speechSynthesizer: AVSpeechSynthesizer?
    @State private var audioSession: AVAudioSession?
    
    var body: some View {
        VStack {
            HStack {
                AppButton(
                    title: "",
                    icon: "backward.fill",
                    type: .secondary,
                    isFullWidth: false
                ) {
                    timerManager.moveToPreviousWorkout()
                }
                
                Spacer()
                
                HoldToExitButton {
                    timerManager.stopTimer()
                    dismiss()
                }
                .frame(width: 180)
                
                Spacer()
                
                AppButton(
                    title: "",
                    icon: "forward.fill",
                    type: .secondary,
                    isFullWidth: false
                ) {
                    timerManager.moveToNextWorkout()
                }
            }
            .padding()
            
            Spacer()
            
            if let preset = preset, !preset.workouts.isEmpty {
                Text(preset.workouts[timerManager.currentWorkoutIndex].name)
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(appearanceManager.fontColor)
                    .padding()
                    .onChange(of: timerManager.currentWorkoutIndex) { oldValue, newValue in
                        let currentWorkoutName = preset.workouts[newValue].name
                        let currentWorkoutTime = preset.workouts[newValue].duration
                        speakWorkoutName(currentWorkoutName, duration: currentWorkoutTime)
                    }
            }
            
            Text(formatTime(timerManager.remainingTime))
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .dynamicTypeSize(...DynamicTypeSize.accessibility5)
                .foregroundColor(appearanceManager.fontColor)
                .padding()
            
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
            
            VStack {
                if timerManager.isWorkoutComplete {
                    AppButton(
                        title: "Complete",
                        type: .primary,
                        isFullWidth: true
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
                            timerManager.startTimer()
                            showControlButtons = false
                        }
                        
                        AppButton(
                            title: "Restart",
                            type: .tertiary,
                            isFullWidth: true
                        ) {
                            timerManager.resetToStart()
                            timerManager.startTimer()
                            showControlButtons = false
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
                timerManager.pauseTimer()
            }
        }
        .background(appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            setupAudioSession()
            setupSpeechSynthesizer()
            
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
                
                if let firstWorkout = preset.workouts.first {
                    timerManager.setRemainingTime(Double(firstWorkout.duration))
                    speakWorkoutName(firstWorkout.name, duration: firstWorkout.duration)
                }
                timerManager.startTimer()
                setTabBarVisibility(hidden: true)
            }
        }
        .onDisappear {
            timerManager.stopTimer()
            SoundManager.shared.stopSound()
            setTabBarVisibility(hidden: false)
            teardownAudioSession()
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
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController {
                tabBarController.tabBar.isHidden = hidden
            }
        }
    }
    
    private func setupAudioSession() {
        do {
            audioSession = AVAudioSession.sharedInstance()
            try audioSession?.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try audioSession?.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func teardownAudioSession() {
        do {
            try audioSession?.setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupSpeechSynthesizer() {
        speechSynthesizer = AVSpeechSynthesizer()
    }
    
    private func speakWorkoutName(_ name: String, duration: Int? = nil) {
        guard !name.isEmpty,
              let synthesizer = speechSynthesizer,
              let audioSession = audioSession else {
            return
        }
        
        do {
            try audioSession.setActive(true)
            
            let language = name.range(of: "\\p{Hangul}", options: .regularExpression) != nil ? "ko-KR" : "en-US"
            guard let voice = AVSpeechSynthesisVoice(language: language) else {
                return
            }
            
            if synthesizer.isSpeaking {
                synthesizer.stopSpeaking(at: .immediate)
            }
            
            let nameUtterance = AVSpeechUtterance(string: name)
            nameUtterance.voice = voice
            nameUtterance.rate = 0.5
            nameUtterance.preUtteranceDelay = 0.1
            
            if let duration = duration {
                let durationText = formatDurationForSpeech(duration)
                if !durationText.isEmpty {
                    let pauseUtterance = AVSpeechUtterance(string: " ")
                    pauseUtterance.voice = voice
                    pauseUtterance.rate = 0.1
                    
                    let durationUtterance = AVSpeechUtterance(string: durationText)
                    durationUtterance.voice = voice
                    durationUtterance.rate = 0.5
                    
                    synthesizer.speak(nameUtterance)
                    synthesizer.speak(pauseUtterance)
                    synthesizer.speak(durationUtterance)
                } else {
                    synthesizer.speak(nameUtterance)
                }
            } else {
                synthesizer.speak(nameUtterance)
            }
        } catch {
            print("Failed to activate audio session for speech: \(error.localizedDescription)")
        }
    }
    
    private func formatDurationForSpeech(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        var text = ""
        
        if minutes > 0 {
            text += "\(minutes) minute" + (minutes > 1 ? "s" : "")
        }
        if seconds > 0 {
            if !text.isEmpty {
                text += " and "
            }
            text += "\(seconds) second" + (seconds > 1 ? "s" : "")
        }
        
        return text
    }
}
