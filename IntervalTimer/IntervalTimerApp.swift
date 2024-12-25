import SwiftUI

@main
struct IntervalTimerApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold)
        ]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appearanceManager)
                .preferredColorScheme(appearanceManager.isDarkMode ? .dark : .light)
        }
    }
}
