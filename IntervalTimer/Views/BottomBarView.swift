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
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(appearanceManager.fontColor)
                    .padding(.leading, 10)
            }
            .frame(height: 50)
            
            Spacer()
            
            Button(action: onSave) {
                HStack {
                    Image(systemName: "checkmark")
                    Text("Save")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .foregroundColor(presetName.isEmpty ? .gray : .black)
                .background(presetName.isEmpty ? Color.gray.opacity(0.6) : Color(UIColor(red: 200/255, green: 236/255, blue: 68/255, alpha: 1)))
                .cornerRadius(8)
            }
            .disabled(presetName.isEmpty)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
