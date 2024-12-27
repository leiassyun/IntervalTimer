import SwiftUI

/// Manages appearance settings for the app.
class AppearanceManager: ObservableObject {
    @Published var appearance: Appearance = .dark
    @Published var fontColor: Color = .white
    @Published var backgroundColor: Color = .black
    @Published var isDarkMode: Bool = false

    init() {
        applyAppearance() // Apply initial appearance
    }

    /// Updates the appearance based on user selection.
    func updateAppearance(_ newAppearance: Appearance) {
        guard appearance != newAppearance else { return }
        appearance = newAppearance
        applyAppearance()
    }

    /// Applies the selected appearance mode.
    func applyAppearance() {
        switch appearance {
        case .system:
            // System appearance will be handled dynamically via Environment in SwiftUI
            break
        case .light:
            setLightMode()
        case .dark:
            setDarkMode()
        }
    }

    /// Applies light mode settings.
    private func setLightMode() {
        fontColor = .black
        backgroundColor = .white
        updateInterfaceStyle(.light)
        isDarkMode = false
    }

    /// Applies dark mode settings.
    private func setDarkMode() {
        fontColor = .white
        backgroundColor = .black
        updateInterfaceStyle(.dark)
        isDarkMode = true
    }

    /// Updates the interface style for the active window.
    private func updateInterfaceStyle(_ style: UIUserInterfaceStyle) {
        guard let window = activeWindow() else {     
            return
        }
        window.overrideUserInterfaceStyle = style
    
    }

    /// Retrieves the active window for the app.
    private func activeWindow() -> UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first
    }
}

/// Enum for appearance options.
enum Appearance: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}
