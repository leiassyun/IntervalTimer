//
//  WorkoutManager.swift
//  IntervalTimer
//
//  Created by Leia Yun on 11/5/24.
//

import SwiftUI
import Combine

class WorkoutManager : ObservableObject{
    @Published var totalSets : Int = 1
    @Published var exerciseTime: Int = 60
    @Published var restTime: Int = 10
    
    @Published var isExercisePhase: Bool = false // True if in exercise phase, false if in rest phase
    @Published var isFinished: Bool = false
    @Published var currentSets: Int = 1
    @Published var timeRemaining: Int = 0
    
    public var timeManager = TimeManager()
    public var cancellables = Set<AnyCancellable>()
    
    init(){
        observeTimer()
    }
    
    func startWorkout(){
        isFinished = false
        currentSets = 1
        isExercisePhase = true
        workoutTimer()
    }
    func pauseWorkout(){
        timeManager.stopTimer()
    }
    func stopWorkout(){
        timeManager.resetTimer()
        isFinished = true
    }
    
    
    func workoutTimer(){
        let duration = isExercisePhase ? exerciseTime : restTime
        timeRemaining = duration
        timeManager.startTimer(for: duration)
    }
    func switchWorkoutPhase(){
        if isExercisePhase {
            isExercisePhase = false
        } else {
            currentSets += 1
            isExercisePhase = true
            if currentSets > totalSets {
                isFinished = true
                return
            }
        }
        workoutTimer()
    }
   
    
    func observeTimer(){
        //Listens for timeRemaining to reach zero, at which point it automatically calls switchPhase()
        timeManager.$timeRemaining
            .sink { [weak self] timeRemaining in
                           guard let self = self else { return }
                           self.timeRemaining = timeRemaining
                           
                           // Check if timer has reached 0 and if the workout should proceed to the next phase
                           if timeRemaining == 0 && self.timeManager.isRunning {
                               self.switchWorkoutPhase()
                           }
                       }
                       .store(in: &cancellables)


        
    }
}
