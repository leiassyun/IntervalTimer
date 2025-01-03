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
        ZStack{
            appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all)
            if showDetail || navigateToShare {
                Color(UIColor(red: 91/255, green: 76/255, blue: 113/255, alpha: 0.9))
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            //<decode: bad range for [%{public}s] got [offs:350 len:1194 within:0]>
            
            VStack {
                
//                Button("Test URL Handling") {
//                    let testURL =
//                    "intervaltimer://share?preset=%257B%2522workouts%2522:%255B%257B%2522duration%2522:5,%2522name%2522:%2522Starts%2520in...%2522,%2522id%2522:%2522EF8B0613-B332-491A-9EEA-EB3A9A29F7BC%2522%257D,%257B%2522duration%2522:1,%2522id%2522:%2522D85C98AC-BF78-41B5-B0E7-3FFD962AC929%2522,%2522name%2522:%2522aa%2522%257D,%257B%2522id%2522:%2522CEF0658A-0102-4D5B-8178-735081D308AC%2522,%2522duration%2522:1,%2522name%2522:%2522D%2522%257D,%257B%2522duration%2522:1,%2522id%2522:%252274256101-D3E8-4B1F-A2F4-0135DC99FAC3%2522,%2522name%2522:%2522A%2522%257D%255D,%2522totalDuration%2522:8,%2522name%2522:%2522Qqq%2522,%2522id%2522:%25228986CE30-C11C-4365-BB0A-5FF43FA34EBF%2522%257D"
//
//                    //   "intervaltimer://share?preset=%257B%2522workouts%2522:%255B%257B%2522name%2522:%2522Starts%2520in...%2522,%2522duration%2522:5,%2522id%2522:%2522F7292319-B00A-4DD8-9D39-7B13D2721591%2522%257D%255D,%2522id%2522:%2522A78CAC42-5383-48F7-B660-9885691A5579%2522,%2522totalDuration%2522:5,%2522name%2522:%2522As%2522%257D"
//                    
//                    appDelegate.testURLHandling(testURL)
//                }
                // Title Bar
                HStack {
                    Text("Preset")
                        .font(.system(.title, weight: .bold))
                        .foregroundColor(appearanceManager.fontColor)
                    Spacer()
                    Button(action: {
                        selectedTab = 2
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top)
                Spacer().frame(height: 20)
                
                
                HStack {
                    Text("Quick start")
                        .font(.system(.title2, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: quickStartExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
                .onTapGesture {
                    withAnimation {
                        quickStartExpanded.toggle()
                    }
                }
                if quickStartExpanded {
                    VStack(alignment: .leading, spacing: 15) {
                        
                      
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
                                .onChange(of: sets) { newValue in
                                    if sets < 1 { sets = 1 }
                                }
                                .onAppear {
                                    sets = 1
                                }
                            
                
                        }
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(appearanceManager.fontColor)
                            Text("Work")
                                .foregroundColor(appearanceManager.fontColor)
                                .font(.system(.title3, weight: .semibold))
                            Spacer()
                            HStack (spacing: 0){
                                TextField(
                                    "",
                                    text: Binding(
                                        get: { String(workoutDuration.minutes) },
                                        set: { newValue in
                                            if let intValue = Int(newValue), intValue >= 0, intValue <= 99 {
                                                workoutDuration.minutes = intValue
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
                                        get: { String(format: "%02d",workoutDuration.seconds) },
                                        set: { newValue in
                                            if let intValue = Int(newValue), intValue >= 0 {
                                                workoutDuration.seconds = intValue
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
                        if sets > 1 {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(appearanceManager.fontColor)
                                    Text("Rest Time")
                                        .foregroundColor(appearanceManager.fontColor)
                                        .font(.system(size: 20, weight: .bold))
                                    
                                    Spacer()
                                    HStack (spacing: 0){
                                        TextField(
                                            "",
                                            text: Binding(
                                                get: { String(restDuration.minutes) },
                                                set: { newValue in
                                                    if let intValue = Int(newValue), intValue >= 0, intValue <= 99 {
                                                        restDuration.minutes = intValue
                                                    }
                                                }
                                            )
                                        )
                                        .keyboardType(.numberPad)
                                        .foregroundColor(appearanceManager.fontColor)
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .frame(minWidth: 30, maxWidth: 45, alignment: .trailing)
                                        .multilineTextAlignment(.trailing)

                                        Text(":")
                                            .foregroundColor(appearanceManager.fontColor)
                                            .font(.system(size: 24, weight: .bold))

                                        TextField(
                                            "00",
                                            text: Binding(
                                                get: { String(restDuration.seconds) },
                                                set: { newValue in
                                                    if let intValue = Int(newValue), intValue >= 0 {
                                                        restDuration.seconds = intValue
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
                            
                            
                        }
                        Button {
                            quickStartPreset = presetManager.createQuickStartPreset(sets: sets, workoutDuration: workoutDuration, restDuration: restDuration)
                            selectedPreset = quickStartPreset
                            navigateToTimer = true
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                    .foregroundColor(appearanceManager.backgroundColor)
                                Text("Play")
                                    .foregroundColor(appearanceManager.backgroundColor)
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(width: 350, height: 50)
                            .background(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                            
                            .cornerRadius(8)
                            .padding(.bottom, 10)
                        }
                        .padding(.top, 5)
                       
                    }
                    .padding(.horizontal, 15)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .transition(.opacity)
                    
                    
                    
                }
                
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(presetManager.presets) { preset in
                            HStack {
                                // Preset Info: Name and Duration
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
                                    
                                    
                                    HStack{
                                        // Play Button
                                        Button {
                                            selectedPreset = preset
                                            navigateToTimer = true
                                        } label: {
                                            HStack {
                                                Image(systemName: "play.fill")
                                                    .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                                                Text("Play")
                                                    .foregroundColor(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                                                    .font(.system(.callout, weight: .semibold))
                                            }
                                            .frame(width: 280, height: 50)
                                            .background(Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 0.15)))
                                            
                                            .cornerRadius(8)
                                        }
                                        
                                        Spacer()
                                        
                                        
                                        Button {
                                            selectedPreset = preset
                                            showDetail = true
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .foregroundColor(appearanceManager.fontColor)
                                        }
                                        .font(.system(size: 20))
                                        .padding()
                                        .background(
                                            Color.gray.opacity(0.3)
                                                .cornerRadius(8)
                                                .frame(height: 50)
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
                                //showDetail = true
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        
                    }
                }
                Spacer()
                
                NavigationLink(
                    destination: IntervalTimerView(preset: selectedPreset),
                    isActive: $navigateToTimer
                ) {
                    EmptyView()
                }
                NavigationLink(
                    destination: AddPresetView(
                        selectedPreset: selectedPreset,
                        presetManager: presetManager,
                        selectedTab: $selectedTab
                    ),
                    isActive: $navigateToAddPreset
                ) {
                    EmptyView()
                }
                
                
            }
            .sheet(isPresented: $showDetail) {
                if let preset = selectedPreset {
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
            }
            
            .sheet(isPresented: $navigateToShare) {
                if let selectedPreset = selectedPreset {
                    ShareView(preset: selectedPreset)
                        .environmentObject(presetManager) // Pass presetManager
                        .presentationDetents([.fraction(0.38)])
                        .presentationDragIndicator(.hidden)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut(duration: 0.3), value: true)
                } else {
                    Text("No preset selected")
                        .font(.headline)
                        .padding()
                }
            }
        }
    }
}
