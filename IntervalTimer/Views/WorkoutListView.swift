import SwiftUI

struct WorkoutListView: View {
    @Binding var workouts: [Workout]
    @Binding var showingTimePicker: Bool
    @Binding var selectedWorkoutIndex: Int?
    @FocusState.Binding var focusedWorkoutIndex: Int?
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        List {
            ForEach(Array(workouts.enumerated()), id: \.element.id) { index, _ in
                WorkoutRowView(
                    index: index,
                    workout: $workouts[index],
                    showingTimePicker: $showingTimePicker,
                    selectedWorkoutIndex: $selectedWorkoutIndex,
                    focusedWorkoutIndex: $focusedWorkoutIndex
                )
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        print("DEBUG: Delete button tapped for workout \(index)")
                        withAnimation {
                            guard index < workouts.count else { return }
                            workouts.remove(at: index)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
            }
            .onMove { source, destination in
                print("DEBUG: Moving workout from index \(source.first!) to \(destination)")
                withAnimation(.default.speed(2.0)) {
                    workouts.move(fromOffsets: source, toOffset: destination)
                }
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, .constant(.active))
    }
}
