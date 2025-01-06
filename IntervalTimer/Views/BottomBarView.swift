import SwiftUI

struct PresetBottomBarView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    @Binding var presetName: String
    let onSave: () -> Void
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                if presetName.isEmpty {
                    Text("Name")
                        .foregroundColor(.gray)
                        .bold()
                        .padding(.leading, 10)
                }
                TextField("", text: $presetName)
                    .font(.title3)
                    .foregroundColor(appearanceManager.fontColor)
                    .padding(.leading, 10)
            }
            
            Spacer()
            
            AppButton(
                title: "Save",
                icon: "checkmark",
                type: .primary,
                isFullWidth: false
            ) {
                onSave()
            }
            .disabled(presetName.isEmpty)
            .opacity(presetName.isEmpty ? 0.6 : 1.0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
