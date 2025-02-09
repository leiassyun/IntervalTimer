import SwiftUI

class AppearanceManager: ObservableObject {
    @Published var appearance: Appearance {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: "SelectedAppearance")
        }
    }
    @Published var fontColor: Color = .white
    @Published var backgroundColor: Color = .black
    @Published var accentColor: Color = .blue

    init() {
        if let savedAppearance = UserDefaults.standard.string(forKey: "appearance"),
           let appearance = Appearance(rawValue: savedAppearance) {
            self.appearance = appearance
        } else {
            self.appearance = .dark
        }
    }

    func updateSystemAppearance(_ appearance: Appearance) {
            self.appearance = appearance
        }
}

enum Appearance: String, CaseIterable {
//    case system = "System"
//    case light = "Light"
    case dark = "Dark"
}
