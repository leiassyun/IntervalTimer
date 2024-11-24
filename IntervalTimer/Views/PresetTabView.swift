import SwiftUI

struct PresetTabView: View {
    @ObservedObject var presetManager: PresetManager
    @Binding var selectedTab: Int // Bind to the tab selection in MainTabView
    @State private var showActionSheet = false
    @State private var selectedPreset: Preset?


    var body: some View {
        VStack {
            HStack {
                Text("Preset")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)

            // List of Added Workouts
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(presetManager.presets) { preset in
                        HStack {
                            // Preset Info: Name and Duration
                            VStack(alignment: .leading, spacing: 8) {
                                Text(preset.name)
                                    .foregroundColor(.white)
                                    .font(.system(size: 24, weight: .bold)) // Larger, bold font for the preset name
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                    Text(preset.name) // Format duration (e.g., 12 min)
                                        .foregroundColor(.gray)
                                        .font(.subheadline)
                                }
                                
                                
                                HStack (alignment: .leading){
                                    
                                    // More Options Button
                                    Button(action: {
                                        // Placeholder action for Play button
                                    }) {
                                        HStack {
                                            Image(systemName: "play.fill")
                                                .foregroundColor(.black)
                                            Text("Play")
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green.opacity(0.8))
                                        .cornerRadius(8)
                                    }
                                    Spacer()
                                    
                                    // More Options Button
                                    Button(action: {
                                        // Placeholder action for More Options button
                                    }) {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(.white)
                                    }
                                    .actionSheet(isPresented: $showActionSheet) {
                                        ActionSheet(
                                            title: Text(selectedPreset?.name ?? "Preset"),
                                            buttons: [
                                                .default(Text("Edit")) {
                                                    // Placeholder action for Edit
                                                },
                                                .default(Text("Duplicate")) {
                                                    // Placeholder action for Duplicate
                                                },
                                                .default(Text("Share")) {
                                                    // Placeholder action for Share
                                                },
                                                .cancel()
                                            ]
                                        )
                                    }
                                    .padding(.leading, 8)
                                }
                            }
                        }
                            
                        .padding()
                        .frame(maxWidth: .infinity) // Make the card take the full width
                        .background(Color.gray.opacity(0.2)) // Card background
                        .cornerRadius(12) // Rounded corners
                        .padding(.horizontal)

                        
                    }
                    Button(action: {
                        selectedTab = 1  // Show workout modal
                    }) {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                            Text("Add preset")
                                .foregroundColor(.gray)
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    Spacer().frame(height: 20)
                }
            }


            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true) // Hide default navigation bar
    }
}
