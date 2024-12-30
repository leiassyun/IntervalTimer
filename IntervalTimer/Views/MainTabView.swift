import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var presetManager : PresetManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                if selectedTab != 2 {
                    TabView(selection: $selectedTab) {
                        PresetTabView(selectedTab: $selectedTab)
                            .tabItem {
                                Text("Preset")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(selectedTab == 0 ? Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)) : Color.gray)
                            }
                            .tag(0)
                        
                        SettingsView(selectedTab: $selectedTab)
                            .tabItem {
                                Text("Menu")
                                    .foregroundColor(selectedTab == 1 ? Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)) : Color.gray)
                            }
                            .tag(1)
                    }
                }
                if selectedTab == 2 {
                    AddPresetView(
                        selectedPreset: nil,
                        presetManager: presetManager,
                        selectedTab: $selectedTab
                    )
                    .transition(.move(edge: .trailing))
                    .zIndex(1) // Bring AddPresetView to the front
                }
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        
        MainTabView()
            .environmentObject(AppearanceManager())
            .environmentObject(PresetManager())     
    }
}
