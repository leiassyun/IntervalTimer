import SwiftUI

struct PresetDetailView: View {
    let preset: Preset
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var navigateToTimer = false // Controls NavigationLink activation
    var onPlay: () -> Void
    var onNavigateToTimer: () -> Void

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
                            .foregroundColor(.green)
                            .font(.headline)
                    }
                    .padding()
                    Button(action: {
                        print("Duplicate tapped")
                    }) {
                        Text("Duplicate")
                            .foregroundColor(.green)
                            .font(.headline)
                    }
                    .padding()
                    Button(action: {
                        print("Edit tapped")
                    }) {
                        Text("Edit")
                            .foregroundColor(.green)
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
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(preset.workouts) { workout in
                        HStack {
                            Text(workout.name)
                                .foregroundColor(appearanceManager.fontColor)
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                            Text(workout.fDuration)
                                .foregroundColor(appearanceManager.fontColor)
                                .font(.system(size: 20, weight: .bold))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                }
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
                                .foregroundColor(Color.green)
                            Text("Play")
                                .foregroundColor(Color.green)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .frame(width: 350, height: 40)
                        .background(Color.green.opacity(0.5))
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .background(appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    }
}
