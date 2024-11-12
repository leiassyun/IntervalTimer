//
//  TimerTestView.swift
//  IntervalTimer
//
//  Created by Leia Yun on 11/5/24.
//
//
//
//import SwiftUI
//
//struct TimerTestView: View {
//    @StateObject private var timeManager = TimeManager() // Observes changes in TimeManager
//
//    var body: some View {
//        VStack {
//            Text("Time Remaining: \(timeManager.timeRemaining)")
//                .font(.largeTitle)
//                .padding()
//
//            HStack {
//                Button(action: {
//                    if timeManager.isRunning {
//                        timeManager.stopTimer()
//                    } else {
//                        timeManager.startTimer(for :timeManager.timeRemaining)
//                    }
//                }) {
//                    Text(timeManager.isRunning ? "Pause" : "Start")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//
//                Button(action: {
//                    timeManager.resetTimer() // Reset to default duration (60 seconds)
//                }) {
//                    Text("Reset")
//                        .padding()
//                        .background(Color.red)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//struct TimerTestView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimerTestView()
//    }
//}
