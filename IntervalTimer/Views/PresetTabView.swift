import SwiftUI

struct PresetTabView: View {
    @ObservedObject var presetManager: PresetManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var selectedTab: Int
    @State private var showActionSheet = false
    @State private var selectedPreset: Preset?
    @State private var navigateToTimer = false
    @State private var showDetail = false
    @State private var isShowingDeleteAlert = false


    
    var body: some View {
        ZStack{
            appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all)
        VStack {
            // Title Bar
            HStack {
                Text("Preset")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(appearanceManager.fontColor)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // List of Presets
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(presetManager.presets) { preset in
                        HStack {
                            // Preset Info: Name and Duration
                            VStack(alignment: .leading, spacing: 8) {
                                Text(preset.name)
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(appearanceManager.fontColor)
                                
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                    Text(preset.fTotalDuration)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                HStack {
                                    // Play Button
                                    Button {
                                        selectedPreset = preset
                                        navigateToTimer = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "play.fill")
                                                .foregroundColor(Color.green)
                                            Text("Play")
                                                .foregroundColor(Color.green)
                                                .font(.system(size: 16, weight: .semibold))
                                        }
                                        .frame(width: 250, height: 40)
                                        .background(Color.green.opacity(0.5))
                                        .cornerRadius(8)
                                    }
                                    
                                    Spacer()
                                    
                                    // More Options Button
                                    Button {
                                        selectedPreset = preset
                                        showActionSheet = true
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .foregroundColor(appearanceManager.fontColor)
                                    }
                                    .padding(.leading, 8)
                                    .frame(width: 30, height: 40, alignment: .center)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .onTapGesture {
                            selectedPreset = preset
                            showDetail = true
                        }
                    }
                    
                    // Add Preset Button
                    Button {
                        selectedTab = 1 // Navigate to Add Preset screen
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                                .foregroundColor(appearanceManager.fontColor)
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
                }
            }
            Spacer()
            NavigationLink(
                destination: selectedPreset.map { IntervalTimerView(preset: $0) },
                isActive: $navigateToTimer
            ) {
                EmptyView()
            }
            
        }
        .sheet(isPresented: $showDetail) {
            if let preset = selectedPreset {
                PresetDetailView(
                    preset: preset,
                    onPlay: {
                        showDetail = false
                        navigateToTimer = true
                    },
                    onNavigateToTimer: {
                        showDetail = false
                        navigateToTimer = true 
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
        
        
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text(""),
                buttons: [
                    .default(Text("Edit")) {
                        print("Edit selected for \(selectedPreset?.name ?? "unknown")")
                    },
                    .default(Text("Duplicate")) {
                        if let presetID = presetManager.presets.first?.id {
                            presetManager.duplicatePreset(presetID: presetID)
                        }
                    },
                    .default(Text("Share")) {
                        print("Share selected for \(selectedPreset?.name ?? "unknown")")
                    },
                    .destructive(Text("Delete")) {
                        isShowingDeleteAlert = true
                    },
                    .cancel()
                ]
            )
        }
        .alert(isPresented: $isShowingDeleteAlert) {
                    Alert(
                        title: Text("Are you sure you want to delete this preset?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let presetID = selectedPreset?.id {
                                            presetManager.deletePreset(by: presetID)
                                            selectedPreset = nil
                                        }
                        },
                        secondaryButton: .cancel()
                    )
                }
    }
}
