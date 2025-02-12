import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var presetManager: PresetManager
    @State private var selectedTab = 0
    @State private var selectedPreset: Preset? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                if selectedTab != 1 {
                    PresetTabView(selectedTab: $selectedTab)
                }
                
                if selectedTab == 1 {
                    AddPresetView(
                        selectedPreset: $selectedPreset,
                        selectedTab: $selectedTab
                    )
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onOpenURL { url in
                    ShareManager.handleIncomingURL(url) { result in
                        switch result {
                        case .success(let preset):
                            DispatchQueue.main.async {
                                presetManager.addPresetP(newPreset: preset)
                            }
                        case .failure(let error):
                            print("MainTabView: Error decoding preset: \(error.localizedDescription)")
                        }
                    }
                }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(PresetManager())
            .environmentObject(AppearanceManager())
    }
}
