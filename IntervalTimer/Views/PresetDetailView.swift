import SwiftUI

struct PresetDetailView: View {
    let preset: Preset
    @ObservedObject var presetManager: PresetManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appearanceManager: AppearanceManager
    @State private var navigateToTimer = false
    @State private var navigateToAddPreset = false
    @State private var isShowingDeleteAlert = false
    @State private var isShareSheetPresented = false
    
    var onPlay: () -> Void
    var onNavigateToTimer: () -> Void
    var onNavigateToAddPreset: () -> Void
    var onNavigateToShare: () -> Void
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(appearanceManager.backgroundColor)
                            .padding(2)
                            .background(Circle().fill(Color.gray.opacity(0.6)))
                            .frame(width: 16, height: 16)
                    }
                    Spacer()
                    Button(action: {
                        isShareSheetPresented = true
                        dismiss()
                        onNavigateToShare()
                    }) {
                        Text("Share")
                            .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                            .font(.headline)
                    }
                    .padding()
                    Menu {
                        Button(action: {
                            navigateToAddPreset = true
                            dismiss()
                            onNavigateToAddPreset()
                            
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        .padding()
                        Button(action: {
                            presetManager.duplicatePreset(presetID: preset.id)
                            dismiss()
                            
                        }) {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        .padding()
                        Button(role: .destructive, action: {
                            isShowingDeleteAlert = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                            .font(.headline)
                            .padding()
                    }
                }
                .padding()
                
                // Preset Title
                Text(preset.name)
                    .foregroundColor(appearanceManager.fontColor)
                    .font(.system(.title2, weight: .bold))
                    .padding(.horizontal)
                ScrollView{
                    // Workout Details
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(preset.workouts) { workout in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(appearanceManager.fontColor)
                                Text(workout.name)
                                    .foregroundColor(appearanceManager.fontColor)
                                    .font(.system(.title3, weight: .semibold))
                                Spacer()
                                Text(workout.fDuration)
                                    .foregroundColor(appearanceManager.fontColor)
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                            }
                            
                            .padding(.vertical, 10)
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                
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
            .alert(isPresented: $isShowingDeleteAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete this preset?"),
                        primaryButton: .destructive(Text("Delete")) {
                            presetManager.deletePreset(presetID: preset.id)
                            dismiss()
                        },
                        secondaryButton: .cancel()
                    )
                }
            
        }
    }
}
