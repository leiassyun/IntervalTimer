import SwiftUI

struct AppTheme {
    // MARK: - Brand Colors
    struct Colors {
        static func primaryFont(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light
            ? Color.white : Color.black
        }
        static func whiteGray(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light
            ? Color.white : Color.gray
        }
        // Dynamic primary color based on the color scheme
        static func primary(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light
                ? Color(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)) // Light
                : Color.orange // Dark
        }

        // Dynamic text color for primary content
        static func primaryText(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light
                ? Color(UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1)) // Light
                : Color.white // Dark
        }

        // Dynamic secondary background color
        static func secondaryBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light
                ? Color(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 0.15)) // Light
                : Color(UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 0.15)) // Dark
        }

        // Dynamic tertiary background color
        static func tertiaryBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .light
                ? Color(UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.12)) // Light
                : Color(UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.12)) // Dark
        }

        // Universal colors for static usage
        static let orange = Color(UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1))
        static let white = Color.white
        static let black = Color.black
    }

    // MARK: - Button Styles
    struct ButtonStyle {
        // Primary Button Style
        struct Primary: ViewModifier {
            @Environment(\.colorScheme) var colorScheme
            let isFullWidth: Bool

            func body(content: Content) -> some View {
                content
                    .foregroundColor(Colors.primary(for: colorScheme))
                    .padding()
                    .frame(height: 50)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .background(Colors.primary(for: colorScheme))
                    .cornerRadius(8)
            }
        }

        // Secondary Button Style
        struct Secondary: ViewModifier {
            @Environment(\.colorScheme) var colorScheme
            let isFullWidth: Bool

            func body(content: Content) -> some View {
                content
                    .foregroundColor(Colors.primary(for: colorScheme))
                    .padding()
                    .frame(height: 50)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .background(Colors.secondaryBackground(for: colorScheme))
                    .cornerRadius(8)
            }
        }

        // Tertiary Button Style
        struct Tertiary: ViewModifier {
            @Environment(\.colorScheme) var colorScheme
            let isFullWidth: Bool

            func body(content: Content) -> some View {
                content
                    .foregroundColor(Colors.primaryFont(for: colorScheme)) // Text color
                    .padding()
                    .frame(height: 50)
                    .frame(maxWidth: isFullWidth ? .infinity : nil)
                    .background(Colors.tertiaryBackground(for: colorScheme))
                    .cornerRadius(8)
            }
        }

        // Top Small Button Style
        struct TopSmall: ViewModifier {
            @Environment(\.colorScheme) var colorScheme
            var foregroundColor: Color
            var backgroundColor: Color

            func body(content: Content) -> some View {
                content
                    .foregroundColor(foregroundColor)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .frame(height:36)
                    .background(backgroundColor)
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

    func topSmallButtonStyle(
        foregroundColor: Color = .primary, // Default color
        backgroundColor: Color = .clear // Default transparent background
    ) -> some View {
        modifier(AppTheme.ButtonStyle.TopSmall(
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor
        ))
    }
}
// MARK: - Reusable Button Components
struct AppButton: View {
    enum ButtonType {
        case primary
        case secondary
        case tertiary
        case topSmall
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
            .padding(.horizontal, type == .topSmall ? 8 : 16)
            .padding(.vertical, type == .topSmall ? 4 : 12)
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
        @Environment(\.colorScheme) var colorScheme

        switch type {
        case .primary:
            self.primaryButtonStyle(isFullWidth: isFullWidth)
                .foregroundColor(foregroundColor ?? AppTheme.Colors.orange)
                .background(backgroundColor ?? AppTheme.Colors.primary(for: colorScheme))
        case .secondary:
            self.secondaryButtonStyle(isFullWidth: isFullWidth)
                .foregroundColor(foregroundColor ?? AppTheme.Colors.primary(for: colorScheme))
                .background(backgroundColor ?? AppTheme.Colors.secondaryBackground(for: colorScheme))
        case .tertiary:
            self.tertiaryButtonStyle(isFullWidth: isFullWidth)
                .foregroundColor(foregroundColor ?? AppTheme.Colors.primaryFont(for: colorScheme))
                .background(backgroundColor ?? AppTheme.Colors.tertiaryBackground(for: colorScheme))
        case .topSmall:
            self.topSmallButtonStyle(
                foregroundColor: foregroundColor ?? AppTheme.Colors.primaryFont(for: colorScheme),
                backgroundColor: backgroundColor ?? .clear
            )
        }
    }
}
