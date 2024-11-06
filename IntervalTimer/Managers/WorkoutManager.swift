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
    
    private var timeManager = TimeManager()
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        //observeTimer()
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
   
    
//    func observeTimer(){
//        //Listens for timeRemaining to reach zero, at which point it automatically calls switchPhase()
//        timeManager.$timeRemaining
//
//        
//    }
}
