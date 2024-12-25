import SwiftUI

struct PresetDetailView: View {
    let preset: Preset
    @ObservedObject var presetManager: PresetManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var navigateToTimer = false 
    @State private var navigateToAddPreset = false // State variable to navigate to AddPresetView
    
    var onPlay: () -> Void
    var onNavigateToTimer: () -> Void
    var onNavigateToAddPreset: () -> Void
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(appearanceManager.fontColor)
                            .padding(7)
                            .background(Circle().fill(Color.gray.opacity(0.6)))
                            .frame(width: 20, height: 20)
                    }
                    Spacer()
                    Button(action: {
                        print("Share tapped")
                    }) {
                        Text("Share")
                            .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                            .font(.headline)
                    }
                    .padding()
                    Button(action: {
                        presetManager.duplicatePreset(presetID: preset.id)
                        dismiss()
                        
                    }) {
                        Text("Duplicate")
                            .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                            .font(.headline)
                    }
                    .padding()
                    Button(action: {
                        navigateToAddPreset = true
                        dismiss()
                        onNavigateToAddPreset()
                        
                    }) {
                        Text("Edit")
                            .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                            .font(.headline)
                    }
                }
                .padding()
                
                // Preset Title
                Text(preset.name)
                    .foregroundColor(appearanceManager.fontColor)
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                
                // Workout Details
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(preset.workouts) { workout in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(appearanceManager.fontColor)
                            Text(workout.name)
                                .foregroundColor(appearanceManager.fontColor)
                                .font(.system(size: 25, weight: .bold))
                            Spacer()
                            Text(workout.fDuration)
                                .foregroundColor(appearanceManager.fontColor)
                                .font(.system(size: 25, weight: .bold))
                        }
                        
                        .padding(.vertical, 10)
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                Spacer()
                
                HStack {
                    Spacer()
                    Button (action: {
                        navigateToTimer = true
                        dismiss()
                        onNavigateToTimer()
                    }) {
                        
                        HStack {
                            Image(systemName: "play.fill")
                                .foregroundColor(.black)
                            Text("Play")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        .background(
                            Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1))
                                .cornerRadius(8)
                                .frame(width: 350, height: 50)
                        )
                        
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .background(appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    }
}
