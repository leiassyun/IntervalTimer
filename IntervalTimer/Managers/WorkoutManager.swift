// Workout Manager
//
//  WorkoutManager.swift
//  IntervalTimer
//
//  Created by Leia Yun on 11/5/24.
//

import SwiftUI
import Combine


class WorkoutManager : ObservableObject {
    @Published var timeRemaining: TimeInterval = 0
    @Published var currentSets: Int = 0
    @Published var isExercisePhase: Bool = true
    @Published var isFinished: Bool = false
    
    public var workoutTimer: Timer?
    public var restTimer: Timer?
    public var workoutInterval: TimeInterval
    public var restInterval: TimeInterval
    public var repeatCount: Int
    

    public var currentRepeat: Int = 0
    
    init(workoutInterval: TimeInterval, restInterval: TimeInterval, repeatCount: Int) {
        self.workoutInterval = workoutInterval
        self.restInterval = restInterval
        self.repeatCount = repeatCount
    }
    
    func start() {
        print("Workout Timer Started")
        isFinished = false
        currentRepeat = 0
        currentSets = 0
        isExercisePhase = true
        timeRemaining = workoutInterval
        startWorkout()
    }
    
    func stop() {
        workoutTimer?.invalidate()
        restTimer?.invalidate()
        print("Workout Timer Stopped")
        isFinished = true
    }
    
    public func startWorkout() {
        if currentRepeat < repeatCount {
            print("Start Workout Interval \(currentRepeat + 1)")
            isExercisePhase = true
            timeRemaining = workoutInterval
            workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                self.timeRemaining -= 1
                if self.timeRemaining <= 0 {
                    timer.invalidate()
                    self.startRest()
                }
            }
        } else {
            print("Workout Completed!")
            isFinished = true
        }
    }
    
    public func startRest() {
        print("Start Rest Interval \(currentRepeat + 1)")
        isExercisePhase = false
        timeRemaining = restInterval
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 {
                timer.invalidate()
                self.currentRepeat += 1
                self.currentSets = self.currentRepeat
                self.startWorkout()
            }
        }
    }
}

//    @Published var totalSets : Int = 1
//    @Published var exerciseTime: Int = 60
//    @Published var restTime: Int = 10
//    
//    @Published var isExercisePhase: Bool = false // True if in exercise phase, false if in rest phase
//    @Published var isFinished: Bool = false
//    @Published var currentSets: Int = 1
//    @Published var timeRemaining: Int = 0
//    
//    public var timeManager = TimeManager()
//    public var cancellables = Set<AnyCancellable>()
//    
//    
//    let timer = Timer.scheduledTimer(withTimeInterval: 0.0, repeats: true) { timer in
//        print("timer executed...")
//    }
//    
//    init() {
//        observeTimer()
//    }
//    
//    func startWorkout() {
//        isFinished = false
//        currentSets = 1
//        isExercisePhase = true
//        workoutTimer()
//    }
//    
//    func pauseWorkout() {
//        timeManager.stopTimer()
//    }
//    
//    func finishWorkout() {
//        timeManager.endTimer()
//        isFinished = true
//        isExercisePhase = false
//    }
//    
//    func workoutTimer() {
//        timeManager.resetTimer(to: isExercisePhase ? exerciseTime : restTime)
//        timeRemaining = isExercisePhase ? exerciseTime : restTime
//        timeManager.startTimer(for: timeRemaining)
//    }
//    
//    func switchWorkoutPhase() {
//        if currentSets >= totalSets && !isExercisePhase {
//            isFinished = true
//            finishWorkout()
//            return
//        }
//        
//        // Switch phase
//        if isExercisePhase {
//            isExercisePhase = false
//            timeRemaining = restTime
//        } else {
//            isExercisePhase = true
//            currentSets += 1
//            timeRemaining = exerciseTime
//        }
//        
//        workoutTimer()
//    }
//    
//    func observeTimer() {
//        // Listens for timeRemaining to reach zero, at which point it automatically calls switchPhase()
//        timeManager.$timeRemaining
//            .sink { [weak self] timeRemaining in
//                guard let self = self else { return }
//                self.timeRemaining = timeRemaining
//                
//                // Check if timer has reached 0 and if the workout should proceed to the next phase
//                if timeRemaining == 0 && self.timeManager.isRunning {
//                    self.switchWorkoutPhase()
//                }
//            }
//            .store(in: &cancellables)
//    }
    
