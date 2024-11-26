import SwiftUI

struct PresetDetailView: View {
    let preset: Preset
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode

    @State private var navigateToTimer = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
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
                .foregroundColor(.white)
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
                
            

            // Workout Details
            VStack(alignment: .leading, spacing: 10) {
                ForEach(preset.workouts) { workout in
                    HStack {
                        Text(workout.name)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Text(workout.fDuration)
                            .foregroundColor(.white)
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
            

            // Play Button
            Button(action: {
                navigateToTimer = true
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Play")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.black)
                .background(Color.green)
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding(.bottom, 20)

            // Navigation to Timer View
            NavigationLink(
                destination: IntervalTimerView(preset: preset),
                isActive: $navigateToTimer
            ) {
                EmptyView()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
