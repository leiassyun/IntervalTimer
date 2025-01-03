import SwiftUI

struct WorkoutRowView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var presetManager: PresetManager
    let index: Int
    @Binding var workout: Workout
    @Binding var showingTimePicker: Bool
    @Binding var selectedWorkoutIndex: Int?
    @FocusState.Binding var focusedWorkoutIndex: Int?
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .foregroundColor(appearanceManager.fontColor)
            
            TextField("Session name", text: $workout.name)
                .font(.system(.title3, weight: .semibold))
                .foregroundColor(appearanceManager.fontColor)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 5)
                .background(Color.clear)
                .focused($focusedWorkoutIndex, equals: index)
            
            Spacer()
            
            Button(action: {
                selectedWorkoutIndex = index
                showingTimePicker = true
            }) {
                Text(formatDuration(workout.duration))
                    .foregroundColor(appearanceManager.fontColor)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color.clear)
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
