import SwiftUI

struct PresetTabView: View {
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var selectedTab: Int
    @State private var showActionSheet = false
    @State private var selectedPreset: Preset?
    @State private var navigateToTimer = false
    @State private var navigateToAddPreset = false
    @State private var navigateToShare = false
    @State private var showDetail = false
    @State private var isShowingDeleteAlert = false
    @State private var quickStartExpanded = false
    @State private var sets: Int = 1
    @State private var workoutDuration: TimeInterval = 60
    @State private var restDuration: TimeInterval = 30
    @State private var quickStartPreset: Preset?
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        NavigationStack {
            ZStack {
                appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all)
                if showDetail || navigateToShare {
                    Color(UIColor(red: 91/255, green: 76/255, blue: 113/255, alpha: 0.9))
                        .ignoresSafeArea()
                        .transition(.opacity)
                }
                
                VStack {
                    // Title Bar
                    HStack {
                        Text("Preset")
                            .font(.system(.title, weight: .bold))
                            .foregroundColor(appearanceManager.fontColor)
                        Spacer()
                        AppButton(
                            title: "",
                            icon: "plus",
                            type: .tertiary,
                            isFullWidth: false,
                            action: {
                                selectedTab = 2
                            }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    Spacer().frame(height: 20)
                    
//                    // Quick Start Section
//                    quickStartSection
                    
                    // Presets ScrollView
                    presetsScrollView
                    
                    Spacer()
                }
                .navigationDestination(isPresented: $navigateToTimer) {
                    if let preset = selectedPreset {
                        IntervalTimerView(preset: preset)
                    }
                }
                .navigationDestination(isPresented: $navigateToAddPreset) {
                    AddPresetView(
                        selectedPreset: selectedPreset,
                        presetManager: presetManager,
                        selectedTab: $selectedTab
                    )
                }
            }
            .sheet(isPresented: $showDetail) {
                if let preset = selectedPreset {
                    presetDetailSheet(preset: preset)
                }
            }
            .sheet(isPresented: $navigateToShare) {
                if let selectedPreset = selectedPreset {
                    shareSheet(preset: selectedPreset)
                } else {
                    Text("No preset selected")
                        .font(.headline)
                        .padding()
                }
            }
        }
    }
    
//    private var quickStartSection: some View {
//        Group {
//            HStack {
//                Text("Quick start")
//                    .font(.system(.title2, weight: .bold))
//                    .foregroundColor(.white)
//                Spacer()
//                Image(systemName: quickStartExpanded ? "chevron.down" : "chevron.up")
//                    .foregroundColor(.white)
//            }
//            .padding()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .background(Color.gray.opacity(0.2))
//            .cornerRadius(10)
//            .padding(.horizontal)
//            .onTapGesture {
//                withAnimation {
//                    quickStartExpanded.toggle()
//                }
//            }
//            
//            if quickStartExpanded {
//                VStack(alignment: .leading, spacing: 15) {
//                    setsInput
//                    workDurationInput
//                    if sets > 1 {
//                        restDurationInput
//                    }
//                    quickStartPlayButton
//                }
//                .padding(.horizontal, 15)
//                .padding(.vertical, 15)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color.gray.opacity(0.2))
//                .cornerRadius(10)
//                .padding(.horizontal)
//                .transition(.opacity)
//            }
//        }
//    }
    
    private var setsInput: some View {
        HStack {
            Text("Sets")
                .font(.system(.title3, weight: .semibold))
                .foregroundColor(appearanceManager.fontColor)
            Spacer()
            TextField("", value: $sets, formatter: NumberFormatter())
                .keyboardType(.numberPad)
                .foregroundColor(appearanceManager.fontColor)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.trailing)
                .onChange(of: sets) { _, newValue in
                    if sets < 1 { sets = 1 }
                }
        }
    }
    
    private var workDurationInput: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(appearanceManager.fontColor)
            Text("Work")
                .foregroundColor(appearanceManager.fontColor)
                .font(.system(.title3, weight: .semibold))
            Spacer()
            durationInputField(
                minutes: Binding(
                    get: { workoutDuration.minutes },
                    set: { workoutDuration.minutes = $0 }
                ),
                seconds: Binding(
                    get: { workoutDuration.seconds },
                    set: { workoutDuration.seconds = $0 }
                )
            )
        }
    }
    
    private var restDurationInput: some View {
        HStack {
            Image(systemName: "clock")
                .foregroundColor(appearanceManager.fontColor)
            Text("Rest Time")
                .foregroundColor(appearanceManager.fontColor)
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            durationInputField(
                minutes: Binding(
                    get: { restDuration.minutes },
                    set: { restDuration.minutes = $0 }
                ),
                seconds: Binding(
                    get: { restDuration.seconds },
                    set: { restDuration.seconds = $0 }
                )
            )
        }
    }
    
    private func durationInputField(
        minutes: Binding<Int>,
        seconds: Binding<Int>
    ) -> some View {
        HStack(spacing: 0) {
            TextField(
                "",
                text: Binding(
                    get: { String(minutes.wrappedValue) },
                    set: { newValue in
                        if let intValue = Int(newValue), intValue >= 0, intValue <= 99 {
                            minutes.wrappedValue = intValue
                        }
                    }
                )
            )
            .keyboardType(.numberPad)
            .foregroundColor(appearanceManager.fontColor)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .frame(minWidth: 30, maxWidth: 50, alignment: .trailing)
            .multilineTextAlignment(.trailing)

            Text(":")
                .foregroundColor(appearanceManager.fontColor)
                .font(.system(size: 24, weight: .bold))

            TextField(
                "00",
                text: Binding(
                    get: { String(format: "%02d", seconds.wrappedValue) },
                    set: { newValue in
                        if let intValue = Int(newValue), intValue >= 0 {
                            seconds.wrappedValue = intValue
                        }
                    }
                )
            )
            .keyboardType(.numberPad)
            .foregroundColor(appearanceManager.fontColor)
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .frame(minWidth: 30, maxWidth: 45, alignment: .trailing)
            .multilineTextAlignment(.trailing)
        }
    }
    
    private var quickStartPlayButton: some View {
        AppButton(
            title: "Play",
            icon: "play.fill",
            type: .primary,
            action: {
                quickStartPreset = presetManager.createQuickStartPreset(
                    sets: sets,
                    workoutDuration: workoutDuration,
                    restDuration: restDuration
                )
                selectedPreset = quickStartPreset
                navigateToTimer = true
            }
        )
        .padding(.top, 5)
    }
    
    private var presetsScrollView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(presetManager.presets) { preset in
                    presetRow(preset)
                }
            }
        }
    }
    
    private func presetRow(_ preset: Preset) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(preset.name)
                    .font(.system(.title2, weight: .bold))
                    .foregroundColor(appearanceManager.fontColor)
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.white)
                    Text(preset.fTotalDuration)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer().frame(height: 3)
                
                HStack {
                    AppButton(
                        title: "Play",
                        icon: "play.fill",
                        type: .secondary,
                        isFullWidth: false,
                        action: {
                            selectedPreset = preset
                            navigateToTimer = true
                        }
                    )
                    
                    Spacer()
                    
                    AppButton(
                        title: "",
                        icon: "ellipsis",
                        type: .tertiary,
                        isFullWidth: false,
                        action: {
                            selectedPreset = preset
                            showDetail = true
                        }
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
        .onTapGesture {
            selectedPreset = preset
        }
    }
    
    private func presetDetailSheet(preset: Preset) -> some View {
        PresetDetailView(
            preset: preset,
            presetManager: presetManager,
            onPlay: {
                showDetail = false
                navigateToTimer = true
            },
            onNavigateToTimer: {
                showDetail = false
                navigateToTimer = true
            },
            onNavigateToAddPreset: {
                showDetail = false
                navigateToAddPreset = true
            },
            onNavigateToShare: {
                showDetail = false
                navigateToShare = true
            }
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.3), value: showDetail)
    }
    
    private func shareSheet(preset: Preset) -> some View {
        ShareView(preset: preset)
            .environmentObject(presetManager)
            .presentationDetents([.fraction(0.38)])
            .presentationDragIndicator(.hidden)
            .transition(.move(edge: .bottom))
            .animation(.easeInOut(duration: 0.3), value: true)
    }
}
