import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var presetManager: PresetManager
    @State private var selectedTab = 0
    @State private var selectedPreset: Preset? = nil 

    
    
    var body: some View {
        NavigationView {
            ZStack {
                if selectedTab != 2 {
                    TabView(selection: $selectedTab) {
                        PresetTabView(selectedTab: $selectedTab)
                            .tabItem {
                                Text("Preset")
                            }
                            .tag(0)
                        
                        SettingsView(selectedTab: $selectedTab)
                            .tabItem {
                                Text("Menu")
                            }
                            .tag(1)
                    }
                    .accentColor(AppTheme.Colors.primary) // This should change the active tab color
                }
                if selectedTab == 2 {
                    AddPresetView(
                        selectedPreset: $selectedPreset,
                        
                        selectedTab: $selectedTab
                    )
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
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
