import SwiftUI
import UIKit

@main
struct IntervalTimerApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var presetManager = PresetManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        configureTabBarAppearance()
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor(AppTheme.Colors.white)
        ]
        
        // Selected state
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(AppTheme.Colors.primary)
        ]
        
        // Set the appearance for different modes
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // If you're supporting iOS 15+, you might want to configure the unified appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appearanceManager)
                .environmentObject(presetManager)
                .environmentObject(appDelegate)
                .preferredColorScheme(appearanceManager.isDarkMode ? .dark : .light)
                .onAppear {
                    appDelegate.presetManager = presetManager
                }
        }
    }
}
