import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var selectedTab: Int

    var body: some View {
        VStack {
            HStack {
                Text("Preferences")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(appearanceManager.fontColor)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
   
            NavigationView {
                Form {
                    Section{
                        HStack(spacing: 20) {
                            appearanceButton(title: "System", image: "gearshape", selectedAppearance: .system)
                            appearanceButton(title: "Light", image: "sun.max", selectedAppearance: .light)
                            appearanceButton(title: "Dark", image: "moon", selectedAppearance: .dark)
                        }
                    }
                }
                .navigationTitle("Appearances")
            }
        }
        .background(appearanceManager.backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            appearanceManager.applyAppearance()
        }
    }

    private func appearanceButton(title: String, image: String, selectedAppearance: Appearance) -> some View {
        Button(action: {
            print("clicked")
            appearanceManager.updateAppearance(.light)
        })  {
            VStack {
                Image(systemName: image)
                    .font(.largeTitle)
                    .foregroundColor(
                        appearanceManager.appearance == selectedAppearance
                            ? appearanceManager.fontColor
                            : appearanceManager.fontColor.opacity(0.5)
                    )
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                appearanceManager.appearance == selectedAppearance
                                    ? appearanceManager.fontColor
                                    : Color.clear,
                                lineWidth: 2
                            )
                    )
                Text(title)
                    .foregroundColor(
                        appearanceManager.appearance == selectedAppearance
                            ? appearanceManager.fontColor
                            : appearanceManager.fontColor.opacity(0.5)
                    )
            }
            .padding(10)
        }
    }
}
