//
//  PresetDetailView.swift
//  IntervalTimer
//
//  Created by Leia Yun on 11/20/24.
//

import SwiftUI

struct PresetDetailView: View {
    let preset: Preset

    var body: some View {
        VStack(spacing: 20) {
            Text(preset.name)
                .font(.largeTitle)
                .padding()

            Text("Workout: \(Int(preset.workoutDuration)) sec")
                .font(.title2)

            Text("Rest: \(Int(preset.restDuration)) sec")
                .font(.title2)

            Text("Repeats: \(preset.repeatCount)")
                .font(.title2)

            Spacer()
        }
        .padding()
        .navigationTitle("Preset Details")
    }
}
