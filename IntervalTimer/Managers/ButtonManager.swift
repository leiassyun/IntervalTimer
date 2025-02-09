import SwiftUI

struct ButtonManager {
    // MARK: - Size Configuration
    struct Sizes {
        struct Icon {
            static let standard: CGFloat = 18
        }
        
        struct Font {
            static let standard: CGFloat = 16
        }
        
        struct Button {
            static let standard: CGFloat = 50
            
            struct Padding {
                static let horizontalStandard: CGFloat = 24
                static let verticalStandard: CGFloat = 12
                static let spacing: CGFloat = 8  // Spacing between icon and text
            }
        }
    }
    
    // MARK: - Brand Colors
    struct Colors {
        static let primaryFont = Color.white
        static let whiteGray = Color.gray
        
        // Main brand color - #C8EC44
        static let primary = Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1))
        
        // Text color for primary content - #1B1B1B
        static let primaryText = Color(UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1))
        
        // Secondary background - #C8EC44 with 15% opacity
        static let secondaryBackground = Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 0.15))
        
        // Tertiary background - #787880 with 12% opacity
        static let tertiaryBackground = Color(UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.12))
    }

    // MARK: - Button Styles
    struct ButtonStyle {
        // Primary Button Style
        struct Primary: ViewModifier {
            let isFullWidth: Bool

            func body(content: Content) -> some View {
                content
                    .foregroundColor(Colors.primaryText)
                    .padding(.horizontal, ButtonManager.Sizes.Button.Padding.horizontalStandard)
                    .padding(.vertical, ButtonManager.Sizes.Button.Padding.verticalStandard)
                    .frame(height: ButtonManager.Sizes.Button.standard)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .background(Colors.primary)
                    .cornerRadius(8)
            }
        }

        // Secondary Button Style
        struct Secondary: ViewModifier {
            let isFullWidth: Bool

            func body(content: Content) -> some View {
                content
                    .foregroundColor(Colors.primary)
                    .padding(.horizontal, ButtonManager.Sizes.Button.Padding.horizontalStandard)
                    .padding(.vertical, ButtonManager.Sizes.Button.Padding.verticalStandard)
                    .frame(height: ButtonManager.Sizes.Button.standard)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .background(Colors.secondaryBackground)
                    .cornerRadius(8)
            }
        }

        // Tertiary Button Style
        struct Tertiary: ViewModifier {
            let isFullWidth: Bool

            func body(content: Content) -> some View {
                content
                    .foregroundColor(.white)
                    .padding(.horizontal, ButtonManager.Sizes.Button.Padding.horizontalStandard)
                    .padding(.vertical, ButtonManager.Sizes.Button.Padding.verticalStandard)
                    .frame(height: ButtonManager.Sizes.Button.standard)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .background(Colors.tertiaryBackground)
                    .cornerRadius(8)
            }
        }

        // Text Only Button Style
        struct TextOnly: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .foregroundColor(Colors.primary)
            }
        }
    }
}

// MARK: - View Extensions for Button Styles
extension View {
    func primaryButtonStyle(isFullWidth: Bool = true) -> some View {
        modifier(ButtonManager.ButtonStyle.Primary(isFullWidth: isFullWidth))
    }

    func secondaryButtonStyle(isFullWidth: Bool = true) -> some View {
        modifier(ButtonManager.ButtonStyle.Secondary(isFullWidth: isFullWidth))
    }

    func tertiaryButtonStyle(isFullWidth: Bool = true) -> some View {
        modifier(ButtonManager.ButtonStyle.Tertiary(isFullWidth: isFullWidth))
    }
    
    func textOnlyButtonStyle() -> some View {
        modifier(ButtonManager.ButtonStyle.TextOnly())
    }
}

// MARK: - Reusable Button Components
struct AppButton: View {
    enum ButtonType {
        case primary
        case secondary
        case tertiary
        case textOnly
    }
    
    let title: String
    let icon: String?
    let type: ButtonType
    let isFullWidth: Bool
    let action: () -> Void
    var foregroundColor: Color? = nil
    var backgroundColor: Color? = nil
    
    init(
        title: String,
        icon: String? = nil,
        type: ButtonType = .primary,
        isFullWidth: Bool = true,
        foregroundColor: Color? = nil,
        backgroundColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.type = type
        self.isFullWidth = isFullWidth
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ButtonManager.Sizes.Button.Padding.spacing) {
                if let icon = icon {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: ButtonManager.Sizes.Icon.standard, height: ButtonManager.Sizes.Icon.standard)
                }
                if !title.isEmpty {
                    Text(title)
                        .font(.system(size: ButtonManager.Sizes.Font.standard, weight: .semibold))
                }
            }
        }
        .switch(type, isFullWidth: isFullWidth, foregroundColor: foregroundColor, backgroundColor: backgroundColor)
    }
}

// MARK: - Helper Extension for Button Type Switching
private extension View {
    @ViewBuilder
    func `switch`(
        _ type: AppButton.ButtonType,
        isFullWidth: Bool,
        foregroundColor: Color?,
        backgroundColor: Color?
    ) -> some View {
        switch type {
        case .primary:
            self.primaryButtonStyle(isFullWidth: isFullWidth)
                .foregroundColor(foregroundColor ?? ButtonManager.Colors.primaryText)
        case .secondary:
            self.secondaryButtonStyle(isFullWidth: isFullWidth)
                .foregroundColor(foregroundColor ?? ButtonManager.Colors.primary)
        case .tertiary:
            self.tertiaryButtonStyle(isFullWidth: isFullWidth)
                .foregroundColor(foregroundColor ?? .white)
        case .textOnly:
            self.textOnlyButtonStyle()
                .foregroundColor(foregroundColor ?? ButtonManager.Colors.primary)
        }
    }
}
