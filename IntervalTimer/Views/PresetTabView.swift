import SwiftUI

struct PresetTabView: View {
    @ObservedObject var presetManager: PresetManager
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var selectedTab: Int
    @State private var showActionSheet = false
    @State private var selectedPreset: Preset?
    @State private var navigateToTimer = false
    @State private var navigateToAddPreset = false
    @State private var navigateToShare = false
    @State private var showDetail = false
    @State private var isShowingDeleteAlert = false
    
    
    
    var body: some View {
        ZStack{
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
                ShareView()
                    .presentationDetents([.fraction(0.38)])
                    .presentationDragIndicator(.hidden)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.3), value: true)
                
            }
        }
       
    }
}
