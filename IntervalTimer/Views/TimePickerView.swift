import SwiftUI

struct TimePickerView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            HStack {
                Picker("Minutes", selection: $minutes) {
                    ForEach(0...60, id: \.self) { minute in
                        Text("\(minute)").tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                
                Text(":")
                    .font(.title2)
                    .bold()
                
                Picker("Seconds", selection: $seconds) {
                    ForEach(0...59, id: \.self) { second in
                        Text(String(format: "%02d", second)).tag(second)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Select Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
