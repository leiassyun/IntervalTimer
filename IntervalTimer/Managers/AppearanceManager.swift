import SwiftUI

/// Manages appearance settings for the app.
class AppearanceManager: ObservableObject {
    // MARK: - Published Properties
    @Published var appearance: Appearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "SelectedAppearance")
        }
    }
    @Published var fontColor: Color = .white
    @Published var backgroundColor: Color = .black
    @Published var accentColor: Color = .blue // Default accent color
    @Published var isDarkMode: Bool = false

    // MARK: - Initializer
    init() {
        if let savedAppearance = UserDefaults.standard.string(forKey: "appearance"),
           let appearance = Appearance(rawValue: savedAppearance) {
            self.appearance = appearance
        } else {
            self.appearance = .system // Default to system appearance
        }
        applyAppearance()
    }

    // MARK: - Core Appearance Logic
    func updateSystemAppearance(_ appearance: Appearance) {
        self.appearance = appearance
        switch appearance {
        case .system:
            // Use the system's dynamic appearance
            break
        case .light:
            setLightMode()
        case .dark:
            setDarkMode()
        }
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
    func toggleMode() {
           isDarkMode.toggle()
       }

    // MARK: - Appearance Mode Management
    /// Applies light mode settings.
    private func setLightMode() {
        fontColor = .black
        backgroundColor = .white
        accentColor = .blue // Light mode accent
        updateInterfaceStyle(.light)
        isDarkMode = false
    }

    /// Applies dark mode settings.
    private func setDarkMode() {
        fontColor = .white
        backgroundColor = .black
        accentColor = .orange // Dark mode accent
        updateInterfaceStyle(.dark)
        isDarkMode = true
    }

    // MARK: - UIKit Integration
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
