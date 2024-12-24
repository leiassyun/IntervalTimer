import SwiftUI

struct MainTabView: View {
    @StateObject private var presetManager = PresetManager()
    @State private var selectedTab = 0 // Tracks the selected tab (0 = Presets, 1 = Add Preset, 2 = Settings)

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                PresetTabView(presetManager: presetManager, selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Presets")
                    }
                    .tag(0)

               
                AddPresetView(
                    selectedPreset: nil, 
                    presetManager: presetManager,
                    selectedTab: $selectedTab
                )
                    .tabItem {
                        Image(systemName: "plus.circle")
                        Text("Add Preset")
                    }
                    .tag(1)

                SettingsView(selectedTab: $selectedTab)
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .tag(2)
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
