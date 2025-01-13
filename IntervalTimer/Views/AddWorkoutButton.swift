import SwiftUI

struct AddWorkoutButton: View {
    @Binding var workouts: [Workout]
    @FocusState.Binding var focusedWorkoutIndex: Int?
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        AppButton(
            title: "Add workout",
            icon: "plus",
            type: .tertiary,
            isFullWidth: true
        ) {
            let newWorkout = Workout(name: "", duration: 60)
            workouts.append(newWorkout)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusedWorkoutIndex = workouts.count - 1
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowSeparator(.hidden)
        .listRowBackground(appearanceManager.backgroundColor) 
    }
}
