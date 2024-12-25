import SwiftUI

struct MainTabView: View {
    @StateObject private var presetManager = PresetManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main TabView
                if selectedTab != 2 { // Hide TabView when selectedTab == 2
                                   TabView(selection: $selectedTab) {
                                       PresetTabView(presetManager: presetManager, selectedTab: $selectedTab)
                                           .tabItem {
                                               Text("Preset")
                                                   .font(.system(size: 50, weight: .bold, design: .default))
                                           }
                                           .tag(0)

                                       SettingsView(selectedTab: $selectedTab)
                                           .tabItem {
                                               Text("Menu")
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
    }
}
