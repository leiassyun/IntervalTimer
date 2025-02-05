import Foundation
import SwiftUI
import UIKit

@MainActor
class TimerManager: ObservableObject {
    @Published private(set) var remainingTime: TimeInterval = 0
    @Published private(set) var isRunning = false
    @Published private(set) var currentWorkoutIndex = 0
    @Published private(set) var isWorkoutComplete = false
    
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var workouts: [Workout] = []
    var onWorkoutComplete: (() -> Void)?
    var onTimerTick: ((TimeInterval) -> Void)?

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        startBackgroundTask()
        UIApplication.shared.isIdleTimerDisabled = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.remainingTime > 0 {
                    self.remainingTime -= 1
                    self.onTimerTick?(self.remainingTime)
                    
                    if self.remainingTime == 0 {
                        self.moveToNextWorkout()
                    }
                }
            }
        }
    }
    
    func setRemainingTime(_ duration: TimeInterval) {
        remainingTime = duration
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func stopTimer() {
        pauseTimer()
        remainingTime = 0
        currentWorkoutIndex = 0
        isWorkoutComplete = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func moveToNextWorkout() {
        guard currentWorkoutIndex < workouts.count - 1 else {
            pauseTimer()
            isWorkoutComplete = true
            onWorkoutComplete?()
            return
        }
        
        currentWorkoutIndex += 1
        remainingTime = Double(workouts[currentWorkoutIndex].duration)
    }
    
    func moveToPreviousWorkout() {
        guard currentWorkoutIndex > 0 else { return }
        currentWorkoutIndex -= 1
        remainingTime = Double(workouts[currentWorkoutIndex].duration)
    }
    
    func resetToStart() {
        stopTimer()
        currentWorkoutIndex = 0
        isWorkoutComplete = false
        if let firstWorkout = workouts.first {
            remainingTime = Double(firstWorkout.duration)
        }
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
              self?.pauseTimer()
              self?.endBackgroundTask()
          }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    deinit {
        @MainActor func cleanup() {
            stopTimer()
            UIApplication.shared.isIdleTimerDisabled = false
        }
        Task { @MainActor in
            cleanup()
        }
    }
}
