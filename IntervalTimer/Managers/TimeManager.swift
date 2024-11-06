//
//  TimeManager.swift
//  IntervalTimer
//
//  Created by Leia Yun on 11/5/24.
//

import Combine
import SwiftUI

class TimeManager : ObservableObject {

    @Published var timeRemaining: Int = 60
    @Published var isRunning: Bool = false


    
    private var timer: AnyCancellable?
    
    
    func startTimer(for time: Int) {
        guard !isRunning else { return }            // Prevents multiple timers from starting at once
        isRunning = true
        timeRemaining = time
     
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink {[weak self] _ in                 //weak reference to prevent memory leaks
                guard let self = self else { return }
                
                if (self.timeRemaining > 0){
                    self.timeRemaining -= 1
                } else {
                    self.stopTimer()
                }
            }
    }
    
    
    func stopTimer() {
        isRunning = false
        timer?.cancel()
    }
    
    func resetTimer(to duration: Int = 60) {
        stopTimer()
        timeRemaining = duration
    }
}
