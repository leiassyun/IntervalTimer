import SwiftUI

struct AppTheme {
    // MARK: - Brand Colors
    struct Colors {
        static let primary = Color(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)) // #FF9500
        static let primaryText = Color(UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1)) // #1B1B1B
        static let secondaryBackground = Color(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.15)) // #FF9500 15%
        static let tertiaryBackground = Color(UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.12)) // #787880 12%
        static let white = Color.white
        static let black = Color.black
    }
    
    // MARK: - Button Styles
    struct ButtonStyle {
        struct Primary: ViewModifier {
            @Environment(\.colorScheme) var colorScheme
            let isFullWidth: Bool
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(colorScheme == .light ? Colors.white : Colors.primaryText)
                    .frame(height: 50)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .padding(.horizontal, isFullWidth ? 0 : 20)
                    .background(Colors.primary)
                    .cornerRadius(8)
            }
        }
        
        struct Secondary: ViewModifier {
            let isFullWidth: Bool
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(Colors.primary)
                    .frame(height: 50)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .padding(.horizontal, isFullWidth ? 0 : 20)
                    .background(Colors.secondaryBackground)
                    .cornerRadius(8)
            }
        }
        
        struct Tertiary: ViewModifier {
            @Environment(\.colorScheme) var colorScheme
            let isFullWidth: Bool
            
            func body(content: Content) -> some View {
                content
                    .foregroundColor(colorScheme == .light ? Colors.primaryText : Colors.white)
                    .frame(height: 50)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .padding(.horizontal, isFullWidth ? 0 : 20)
                    .background(Colors.tertiaryBackground)
                    .cornerRadius(8)
            }
        }
    }
}

// MARK: - View Extensions for Button Styles
extension View {
    func primaryButtonStyle(isFullWidth: Bool = true) -> some View {
        modifier(AppTheme.ButtonStyle.Primary(isFullWidth: isFullWidth))
    }
    
    func secondaryButtonStyle(isFullWidth: Bool = true) -> some View {
        modifier(AppTheme.ButtonStyle.Secondary(isFullWidth: isFullWidth))
    }
    
    func tertiaryButtonStyle(isFullWidth: Bool = true) -> some View {
        modifier(AppTheme.ButtonStyle.Tertiary(isFullWidth: isFullWidth))
    }
}

// MARK: - Reusable Button Components
struct AppButton: View {
    enum ButtonType {
        case primary
        case secondary
        case tertiary
    }
    
    let title: String
    let icon: String?
    let type: ButtonType
    let isFullWidth: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        type: ButtonType = .primary,
        isFullWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.type = type
        self.isFullWidth = isFullWidth
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                if !title.isEmpty {
                    Text(title)
                        .font(.headline)
                }
            }
            .padding(.horizontal, 16)
        }
        .switch(type, isFullWidth: isFullWidth)
    }
}

// Helper extension for button type switching
private extension View {
    @ViewBuilder
    func `switch`(_ type: AppButton.ButtonType, isFullWidth: Bool) -> some View {
        switch type {
        case .primary:
            self.primaryButtonStyle(isFullWidth: isFullWidth)
        case .secondary:
            self.secondaryButtonStyle(isFullWidth: isFullWidth)
        case .tertiary:
            self.tertiaryButtonStyle(isFullWidth: isFullWidth)
        }
    }
}
