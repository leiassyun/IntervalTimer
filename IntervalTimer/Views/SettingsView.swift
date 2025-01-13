import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Settings")
                .font(.system(.title, weight: .bold))
                .foregroundColor(appearanceManager.fontColor)
                .padding(.top)
                .padding(.horizontal)
            
            Spacer().frame(height: 30)
            
            // Appearances Section
            Text("Appearance")
                .font(.system(.title2, weight: .bold))
                .foregroundColor(appearanceManager.fontColor)
                .padding(.horizontal)
            
            // Buttons for Appearance Modes
            HStack(spacing: 16) {
                appearanceButton(title: "System", image: "gearshape", selectedAppearance: .system)
                appearanceButton(title: "Light", image: "sun.max", selectedAppearance: .light)
                appearanceButton(title: "Dark", image: "moon", selectedAppearance: .dark)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            Spacer()
        }
        
        .onAppear {
            appearanceManager.applyAppearance()
        }
        .background(appearanceManager.backgroundColor)
    }
    
    
    // Appearance Button Component
    private func appearanceButton(title: String, image: String, selectedAppearance: Appearance) -> some View {
        Button(action: {
            appearanceManager.updateSystemAppearance(selectedAppearance)
        }) {
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: image)
                    .font(.system(size: 24))
                    .foregroundColor(appearanceManager.fontColor)
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(appearanceManager.fontColor)
            }
            .padding()
            .frame(width: 110, height: 110)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(appearanceManager.appearance == selectedAppearance
                          ? appearanceManager.fontColor.opacity(0.1)
                          : Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        appearanceManager.appearance == selectedAppearance
                        ? appearanceManager.fontColor
                        : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
