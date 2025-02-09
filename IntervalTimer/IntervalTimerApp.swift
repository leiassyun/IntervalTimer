import SwiftUI
import UIKit

@main
struct IntervalTimerApp: App {
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var presetManager = PresetManager()
    
    init() {
        configureTabBarAppearance()
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appearanceManager)
                .environmentObject(presetManager)
                .ignoresSafeArea()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor.gray
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(Color(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)))
        ]
        
        appearance.backgroundEffect = nil
        appearance.backgroundColor = UIColor.clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
} 



