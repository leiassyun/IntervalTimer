// Timer
//
//  TimeManager.swift
//  IntervalTimer
//
//  Created by Leia Yun on 11/5/24.
//

import Combine
import SwiftUI

class TimeManager : ObservableObject {

    private var timer: Timer?
    private var interval: TimeInterval
    private var repeats: Bool
    private var action:  (() -> Void)?
    private var isPaused: Bool = true
    private var remainingTime: TimeInterval?
    
    init(interval: TimeInterval, repeats: Bool, action: @escaping () -> Void) {
        self.interval = interval
        self.repeats = repeats
        self.action = action
    }
    
    func startTimer() {
        stopTimer()
        if let remainingTime = remainingTime, isPaused {
            timer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: repeats) { [weak self] _ in
                self?.action?()
                if !self!.repeats {
                    self?.isPaused = false
                }
            }
            isPaused = false
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { [weak self] _ in
                self?.action?()
            }
        }
        
    }
    func stopTimer() {
            if !isPaused {
                isPaused = true
                timer?.invalidate()
            }
        }
        
    func resumeTimer() {
        if isPaused {
            if let remainingTime = remainingTime, isPaused {
                timer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: repeats) { [weak self] _ in
                    self?.action?()
                    if !self!.repeats {
                        self?.isPaused = false
                    }
                }
            }
            isPaused = false
        }
    }
    
  
    func reset() {
        stopTimer()
        remainingTime = nil
        isPaused = false
        startTimer()
    }
    
//    func startTimer(for time: Int) {
//        guard !isRunning else { return }            // Prevents multiple timers from starting at once
//        isRunning = true
//        runTime(for:time)
//    }
//    
//    func runTime(for time: Int){
//        timeRemaining = time
//        timer = Timer.publish(every: 1, on: .main, in: .common)
//            .autoconnect()
//            .sink { [weak self] _ in
//                guard let self = self else { return }
//                if self.timeRemaining > 0 {
//                    self.timeRemaining -= 1
//                } else {
//                    self.stopTimer()
//                }
//            }
//    }
//    
//    func stopTimer() {
//        timer?.cancel()
//    }
//    
//    func endTimer(){
//        stopTimer()
//        isRunning = false
//    }
//    
//    func resetTimer(to duration: Int) {
//        endTimer()
//        timeRemaining = duration
//    }
}
