import SwiftUI

@main
struct IntervalTimerApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var presetManager = PresetManager()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
            
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)

        ]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appearanceManager)
                .environmentObject(presetManager)
                .preferredColorScheme(appearanceManager.isDarkMode ? .dark : .light)
        }
    }
}
