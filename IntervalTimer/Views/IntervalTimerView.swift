////
////  IntervalTimerView.swift
////  IntervalTimer
////
////  Created by Leia Yun on 11/20/24.
////
//
////
////  IntervalTimerView.swift
////  IntervalTimer
////
////  Created by Leia Yun on 11/20/24.
////
////
////  PresetTabView.swift
////  IntervalTimer
////
////  Created by Leia Yun on 11/20/24.
////
//
//
//import SwiftUI
//
//struct Preset: Identifiable {
//    let id = UUID()
//    var name: String
//    var workoutDuration: TimeInterval
//    var restDuration: TimeInterval
//    var repeatCount: Int
//}
//
//class PresetManager: ObservableObject {
//    @Published var presets: [Preset] = [
//        Preset(name: "Quick Start", workoutDuration: 60, restDuration: 20, repeatCount: 3)
//    ]
//}
//
//struct PresetTabView: View {
//    @StateObject private var presetManager = PresetManager()
//    @State private var isAddingPreset = false
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                if presetManager.presets.isEmpty {
//                    Text("No presets added yet.")
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    List(presetManager.presets) { preset in
//                        NavigationLink(destination: PresetDetailView(preset: preset)) {
//                            HStack {
//                                Text(preset.name)
//                                    .font(.headline)
//                                Spacer()
//                                Text("\(preset.repeatCount)x")
//                                    .foregroundColor(.gray)
//                                    .font(.subheadline)
//                            }
//                        }
//                    }
//                }
//            }
//            .navigationTitle("Preset")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        isAddingPreset.toggle()
//                    }) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .sheet(isPresented: $isAddingPreset) {
//                AddPresetView(presetManager: presetManager)
//            }
//        }
//    }
//}
//
//struct PresetDetailView: View {
//    let preset: Preset
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text(preset.name)
//                .font(.largeTitle)
//                .padding()
//
//            Text("Workout: \(Int(preset.workoutDuration)) sec")
//                .font(.title2)
//
//            Text("Rest: \(Int(preset.restDuration)) sec")
//                .font(.title2)
//
//            Text("Repeats: \(preset.repeatCount)")
//                .font(.title2)
//
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Preset Details")
//    }
//}
//
//struct AddPresetView: View {
//    @ObservedObject var presetManager: PresetManager
//    @Environment(\.dismiss) var dismiss
//
//    @State private var presetName = ""
//    @State private var workoutDuration = 60.0
//    @State private var restDuration = 20.0
//    @State private var repeatCount = 3
//
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Preset Name")) {
//                    TextField("Enter name", text: $presetName)
//                }
//
//                Section(header: Text("Workout Duration")) {
//                    Stepper(value: $workoutDuration, in: 10...600, step: 10) {
//                        Text("\(Int(workoutDuration)) seconds")
//                    }
//                }
//
//                Section(header: Text("Rest Duration")) {
//                    Stepper(value: $restDuration, in: 10...600, step: 10) {
//                        Text("\(Int(restDuration)) seconds")
//                    }
//                }
//
//                Section(header: Text("Repeat Count")) {
//                    Stepper(value: $repeatCount, in: 1...20, step: 1) {
//                        Text("\(repeatCount) times")
//                    }
//                }
//            }
//            .navigationTitle("Add Preset")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") {
//                        dismiss()
//                    }
//                }
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Save") {
//                        let newPreset = Preset(
//                            name: presetName,
//                            workoutDuration: workoutDuration,
//                            restDuration: restDuration,
//                            repeatCount: repeatCount
//                        )
//                        presetManager.presets.append(newPreset)
//                        dismiss()
//                    }
//                    .disabled(presetName.isEmpty)
//                }
//            }
//        }
//    }
//}
//
//struct PresetTabView_Previews: PreviewProvider {
//    static var previews: some View {
//        PresetTabView()
//    }
//}
