import SwiftUI

struct WorkoutRowView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    let index: Int
    @Binding var workout: Workout
    @Binding var showingTimePicker: Bool
    @Binding var selectedWorkoutIndex: Int?
    @FocusState.Binding var focusedWorkoutIndex: Int?
    @Binding var isEditing: Bool
    @State private var draggedWorkout: Workout? = nil
    
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)
                .frame(width: 20)
                .padding(.leading, 16)
                .contentShape(Rectangle())
                .onTapGesture {
                    isEditing.toggle()
                    print(isEditing)
                }
                .onDrag {
                    guard isEditing else { return NSItemProvider() } 
                    draggedWorkout = workout
                    return NSItemProvider(object: "\(index)" as NSString)
                }
            
            
            
            TextField("Session name", text: $workout.name)
                .font(.system(.title3, weight: .semibold))
                .foregroundColor(appearanceManager.fontColor)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.vertical, 5)
                .focused($focusedWorkoutIndex, equals: index)
                .frame(maxWidth: .infinity, alignment: .leading)
            
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
        
        .onTapGesture {
            focusedWorkoutIndex = index
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                print("Delete workout at index \(index)")
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
            
        }
    }
    
    private func formatDuration(_ duration: Int) -> String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
