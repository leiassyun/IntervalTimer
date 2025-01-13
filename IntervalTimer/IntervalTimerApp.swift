import SwiftUI
import UIKit

@main
struct IntervalTimerApp: App {
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var appearanceManager = AppearanceManager()
    @StateObject private var presetManager = PresetManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        configureTabBarAppearance()
    }
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appearanceManager)
                .environmentObject(presetManager)
                .environmentObject(appDelegate)
                .preferredColorScheme(appearanceManager.isDarkMode ? .dark : .light)
                .background(
                    appearanceManager.isDarkMode ? Color.black : Color.white
                )
                .edgesIgnoringSafeArea(.all)
                .onChange(of: appearanceManager.isDarkMode) { _ in
                    configureTabBarAppearance()
                    if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                        tabBarController.tabBar.standardAppearance = UITabBar.appearance().standardAppearance
                        if #available(iOS 15.0, *) {
                            tabBarController.tabBar.scrollEdgeAppearance = UITabBar.appearance().scrollEdgeAppearance
                        }
                    }
                }
                .onAppear {
                    configureTabBarAppearance()
                }
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // Normal state
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .medium),
            .foregroundColor: UIColor(Color.gray)
        ]
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(Color(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)))
        ]
        
        appearance.backgroundEffect = nil
        appearance.backgroundColor = UIColor.clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // iOS 15+ unified appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
}
