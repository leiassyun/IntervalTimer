import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack (alignment: .leading) {
            
            Text("Settings")
                .font(.system(.title, weight: .bold))
                .foregroundColor(appearanceManager.fontColor)
                .padding(.top)
                .padding(.horizontal)
            
            
            
            Spacer().frame(height:30)
            
            Text("Appearances")
                .font(.system(.title2, weight: .bold))
                .foregroundColor(appearanceManager.fontColor)
                .padding(.horizontal)
            
            HStack(spacing: 16) {
                appearanceButton(title: "System", image: "gearshape", selectedAppearance: .system)
                appearanceButton(title: "Light", image: "sun.max", selectedAppearance: .light)
                appearanceButton(title: "Dark", image: "moon", selectedAppearance: .dark)
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            
            
        }
        .background(appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            appearanceManager.applyAppearance()
        }
    }
    private func appearanceButton(title: String, image: String, selectedAppearance: Appearance) -> some View {
        Button(action: {
            appearanceManager.updateAppearance(selectedAppearance)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                Spacer().frame(height:5)
                Image(systemName: image)
                    .font(.system(.subheadline))
                    .foregroundColor(appearanceManager.fontColor)
                    .padding(.trailing, 40)
                
                Text(title)
                    .font(.system(.subheadline))
                    .foregroundColor(appearanceManager.fontColor)
                    .padding(.trailing, 20)
                Spacer()
                
            }
            .padding(.horizontal,15)
            .frame(width: 110, height: 110)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(appearanceManager.appearance == selectedAppearance
                          ? Color.clear
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
