import Foundation
import SwiftUI

@MainActor
class TimerManager: ObservableObject {
    @Published private(set) var remainingTime: TimeInterval = 0
    @Published private(set) var isRunning = false
    @Published private(set) var currentWorkoutIndex = 0
    @Published private(set) var isWorkoutComplete = false
    
    private var timerTask: Task<Void, Never>?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var workouts: [Workout] = []
    var onWorkoutComplete: (() -> Void)?
    var onTimerTick: ((TimeInterval) -> Void)?

    func startTimer() async {
        guard !isRunning else { return }
        isRunning = true
        startBackgroundTask()
        
        timerTask = Task {
            while !Task.isCancelled && isRunning {
                if remainingTime > 0 {
                    remainingTime -= 1
                    onTimerTick?(remainingTime)
                    
                    // Check if we need to move to next workout
                    if remainingTime == 0 {
                        await moveToNextWorkout()
                    }
                }
                
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            }
        }
    }
    
    func setRemainingTime(_ duration: TimeInterval) {
        remainingTime = duration
    }
    
    func pauseTimer() async {
        isRunning = false
        timerTask?.cancel()
        timerTask = nil
        endBackgroundTask()
    }
    
    func stopTimer() async {
        await pauseTimer()
        remainingTime = 0
        currentWorkoutIndex = 0
    }
    
    func moveToNextWorkout() async {
        guard currentWorkoutIndex < workouts.count - 1 else {
            await stopTimer()
            isWorkoutComplete = true
            onWorkoutComplete?()
            return
        }
        
        currentWorkoutIndex += 1
        remainingTime = Double(workouts[currentWorkoutIndex].duration)
    }
    
    func moveToPreviousWorkout() async {
        guard currentWorkoutIndex > 0 else { return }
        currentWorkoutIndex -= 1
        remainingTime = Double(workouts[currentWorkoutIndex].duration)
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            Task { @MainActor [weak self] in
                await self?.stopTimer()
            }
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func resetToStart() async {
        await stopTimer()
        currentWorkoutIndex = 0
        isWorkoutComplete = false
        if let firstWorkout = workouts.first {
            remainingTime = Double(firstWorkout.duration)
        }
    }
    
    deinit {
        Task { @MainActor in
            await stopTimer()
        }
    }
}
