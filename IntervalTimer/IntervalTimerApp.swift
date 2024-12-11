import SwiftUI

@main
struct IntervalTimerApp: App {
    @StateObject private var appearanceManager = AppearanceManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appearanceManager)

        }
    }
}
