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
                
                Button("Test URL Handling") {
                    let testURL =
                    "intervaltimer://share?preset=%257B%2522workouts%2522:%255B%257B%2522duration%2522:5,%2522name%2522:%2522Starts%2520in...%2522,%2522id%2522:%2522EF8B0613-B332-491A-9EEA-EB3A9A29F7BC%2522%257D,%257B%2522duration%2522:1,%2522id%2522:%2522D85C98AC-BF78-41B5-B0E7-3FFD962AC929%2522,%2522name%2522:%2522aa%2522%257D,%257B%2522id%2522:%2522CEF0658A-0102-4D5B-8178-735081D308AC%2522,%2522duration%2522:1,%2522name%2522:%2522D%2522%257D,%257B%2522duration%2522:1,%2522id%2522:%252274256101-D3E8-4B1F-A2F4-0135DC99FAC3%2522,%2522name%2522:%2522A%2522%257D%255D,%2522totalDuration%2522:8,%2522name%2522:%2522Qqq%2522,%2522id%2522:%25228986CE30-C11C-4365-BB0A-5FF43FA34EBF%2522%257D"
                    //"intervaltimer://share?preset=%257B%2522name%2522:%2522f%2522,%2522workouts%2522:%255B%257B%2522duration%2522:5,%2522name%2522:%2522Starts%2520in...%2522,%2522id%2522:%25222449681F-90CC-49B1-BDD1-09F00D316AD6%2522%257D,%257B%2522name%2522:%2522%2522,%2522duration%2522:1,%2522id%2522:%2522363256AF-D092-426A-AFEC-B91DCD1AF5E0%2522%257D,%257B%2522id%2522:%2522C4F37535-B7CF-4D99-A5B9-936531F910DD%2522,%2522duration%2522:1,%2522name%2522:%2522%2522%257D%255D,%2522totalDuration%2522:7,%2522id%2522:%25228054012B-52AE-466A-8BCB-33F59E4309C4%2522%257D"
                    //   "intervaltimer://share?preset=%257B%2522workouts%2522:%255B%257B%2522name%2522:%2522Starts%2520in...%2522,%2522duration%2522:5,%2522id%2522:%2522F7292319-B00A-4DD8-9D39-7B13D2721591%2522%257D%255D,%2522id%2522:%2522A78CAC42-5383-48F7-B660-9885691A5579%2522,%2522totalDuration%2522:5,%2522name%2522:%2522As%2522%257D"
                    
                    appDelegate.testURLHandling(testURL)
                }
                // Title Bar
                HStack {
                    Text("Preset")
                        .font(.title)
                        .bold()
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
                
                Button {
                    //selectedTab = 1
                } label: {
                    HStack {
                        
                        Text("Quick Start")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(appearanceManager.fontColor)
                        
                        Spacer()
                        //Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                            .padding(8)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                }
                //                if isExpanded {
                //                                VStack(alignment: .leading, spacing: 10) {
                //                                    Text("Option 1")
                //                                    Text("Option 2")
                //                                    Text("Option 3")
                //                                }
                //                                .padding()
                //                                .background(Color.black.opacity(0.1))
                //                                .cornerRadius(8)
                //                                .transition(.opacity)
                //                            }
                //                        }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(presetManager.presets) { preset in
                            HStack {
                                // Preset Info: Name and Duration
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(preset.name)
                                        .font(.system(size: 20, weight: .bold))
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
                                                    .font(.system(size: 16, weight: .semibold))
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
