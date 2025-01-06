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
                        type: .tertiary,
                        isFullWidth: false
                    ) {
                        dismiss()
                    }
                    
                    Spacer()
                    
                    AppButton(
                        title: "Share",
                        type: .secondary,
                        isFullWidth: false
                    ) {
                        isShareSheetPresented = true
                        dismiss()
                        onNavigateToShare()
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
