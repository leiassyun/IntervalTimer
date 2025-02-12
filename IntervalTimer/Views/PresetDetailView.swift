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
                    AppButton(
                        title: "",
                        icon: "xmark",
                        type: .textOnly,
                        isFullWidth: false
                    ) {
                        dismiss()
                    }
                    
                    Spacer()
    
                    if let shareURL = ShareManager.generateShareURL(for: preset) {
                        ShareLink(item: shareURL,
                                  subject: Text("Check out my workout preset!"),
                                  message: Text("I've been using this great workout preset for my intervals. Try it out!")) {
                            Text("Share")
                                .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                                .font(.headline)
                                .padding()

                        }
                    } else {
                        Text("Unable to generate a shareable URL.")
                            .foregroundColor(.red)
                            .padding()
                    }
                    
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
                    } label: {
                        AppButton(
                            title: "",
                            icon: "ellipsis",
                            type: .secondary,
                            isFullWidth: false
                        ) {
                            // Menu handles the action
                        }
                    }
                }
                .padding()
                
                // Preset Title
                Text(preset.name)
                    .foregroundColor(appearanceManager.fontColor)
                    .font(.system(.title2, weight: .bold))
                    .padding(.horizontal)
                
                ScrollView {
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
                    AppButton(
                        title: "Play",
                        icon: "play.fill",
                        type: .primary,
                        isFullWidth: true
                    ) {
                        navigateToTimer = true
                        dismiss()
                        onNavigateToTimer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .background(appearanceManager.backgroundColor.ignoresSafeArea())
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
